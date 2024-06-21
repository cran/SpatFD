sim_functional_process <- function(nsims,variograms,nbasis,coords,data = NULL,
                                   data_coords = NULL,basis = NULL,mu = NULL,L = NULL){
  # Arguments validation ----
  
  ## nsims ----
  if(!all(is.numeric(nsims),nsims>0))
    stop("nsims must be a positive integer.")
  nsims |> as.integer() -> nsims
  
  ## nbasis ----
  if(!all(is.numeric(nsims),nsims>0))
    stop("nsims must be a positive integer.")
  nsims |> as.integer() -> nsims
  
  ## variograms ----
  if("list" %in% class(variograms)){
    if(length(variograms) == nbasis){
      if(!all(sapply(variograms,
                     FUN = \(x)(inherits(x,"variogramModel")))))
        stop("All the passed variograms must be of class variogramModel.")
    }else{
      stop(paste("variograms must be a single variogram or a list of",nbasis," variograms."))
    }
  }else{
    if(!inherits(variograms,"variogramModel"))
      stop("If a single variogram is passed, it must be of class variogramModel.")
    
    # Repeat single variogram nbasis times.  
    variograms <- lapply(1:nbasis,FUN = \(x)(variograms))
  }

  ## data ----
  if(is.null(data)){
    cond <- FALSE
  }else{
    if(!inherits(data,"fd"))
      stop("data must be of class fd.")
    cond <- TRUE
  }
  
  ## coords ----
  if(!inherits(coords,"SpatialPoints")){
    if(!all(inherits(coords,"array"),
            length(dim(coords))== 2,
            dim(coords)[2] == 2,
            is.numeric(coords)))
      stop("coords must be a SpatialPoints object or nsimsx2 numeric array.")
    
    coords <- sp::SpatialPoints(coords)
    
  }
  
  if(cond)
    sp::gridded(coords) <- TRUE
  
  n_points <- length(coords)
  
  ## data_coords ----
  if(cond){
    if(!inherits(data_coords,"SpatialPoints")){
      if(!all(inherits(data_coords,"array"),
              length(dim(data_coords))== 2,
              dim(data_coords)[2] == 2,
              is.numeric(data_coords)))
        stop("data_coords must be a SpatialPoints object or ncol(canada$coefs)x2 numeric array.")
      
      data_coords <- sp::SpatialPoints(data_coords)
    }
  }
  
  ## basis ----
  if(!cond)
    if(!is.character(basis)){
      stop("basis must be one of the following characters: 'Fourier', 'Legendre'.")
    }else{
      if(!(basis %in% c('Fourier','Legendre')))
        stop("basis must be one of the following characters: 'Fourier', 'Legendre'.")
    }
  
  ## mu ----
  if(!is.null(mu))
    if(!inherits(mu,"fd"))
      stop("mu must be of class fd.")
    

  
  
  if(!cond){
    
    # Inconditional simulation ----
    
    ## Covariances matrix ----
    
    dists_matrix <- sp::spDists(coords,coords) |> as.matrix()
    cov_matrices <- lapply(variograms,
                           FUN = \(v)(gstat::variogramLine(v,
                                                    dist_vector = dists_matrix,
                                                    covariance = TRUE)))
    
    ## Simulate scores ----
    
    sapply(cov_matrices,
           FUN = \(Sig)(MASS::mvrnorm(n = nsims,
                                      mu = rep(0,n_points),
                                      Sigma = Sig)),
           simplify = "array") -> sims
    
    
    # dim(sims): nsims x n_points x nbasis
    
  
  }else{
  
    # Conditional simulation ----
  
    ## FPCA ----
    fpca <- fda::pca.fd(data,nharm = nbasis)
    
    # Varianza explicada
    lambs <- fpca$values
    prop_var <- sum(lambs[1:nbasis])/sum(lambs)
    cat(nbasis," basis functions explain ",round(100*prop_var,1),"% of variability.\n",sep = "")
    # R^p data
    scores <- fpca$scores
    scores.df <- data.frame(scores)
    names(scores.df) <- paste0("SC",1:nbasis)
    scores.sp <- sp::SpatialPointsDataFrame(data_coords,scores.df)
    # Functional mean
    mu <- fpca$meanfd
    
    ## Simulate scores ----
    cat("pre-warning\n")
    lapply(1:nbasis,FUN = function(i){
      formula.i <- as.formula(paste0("SC",i," ~ 1"))
      .krigeSimCE(formula.i,scores.sp,newdata = coords,
                 model = variograms[[i]],n = nsims) -> sims.i
      return(sims.i@data)
    }) -> sims_per_score
    cat("post-warning\n")
    # print(warnings())
    
    sims <- sapply(sims_per_score,
                   FUN = \(ar)(t(ar)),
                   simplify = "array")
    
    # dim(sims): nsims x n_points x nbasis
    
  }
  
  
  # Build curves (KL) ----
  
  lapply(1:nsims,FUN = function(i){
    
    # Base
    if(cond){
      basis <- fpca$harmonics
    }else{
      basis <- generate_basis(basis = basis,
                              n_functions = nbasis,
                              L = L,
                              fda_basis = mu$basis)
    }
    
    new_data <- list()
    new_data$coefs <- basis$coefs %*% t(sims[i,,]) # (nsplines x nbasis) %*% t(npoints x nbasis) = (nsplines x npoints)
    
    
    # Add mean
    if(!is.null(mu)){
      # mu está en una base distinta a la de los datos, toca actualizar su base
      mu_coefs <- mu$coefs %*% t(rep(1,n_points))
      new_data$coefs <- mu_coefs + new_data$coefs
    }
    
    new_data$basis <- basis$basis
    
    new_data$fdnames <- list()
    
    if(cond){
      new_data$fdnames$time <- data$fdnames$time
    }else{
      new_data$fdnames$time <- basis$fdnames$time
      # if(is.null(mu)){
      #   new_data$fdnames$time <- basis$time
      # }else{
      #   new_data$fdnames$time <- mu$fdnames$time
      #   
      # }
    }
    
    new_data$fdnames$reps <- 1:n_points # OBSERVACION: Se podrían poner los nombres de las coordenadas a muestrear, si tienen alguno
    new_data$fdnames$values <- "value"
    
    attr(new_data,"class") <- "fd"
    
    return(new_data)
    
  }) -> sims.fd
  
  
  # Convert to spatfd objects
  lapply(sims.fd,FUN = function(fd){
    fpca <- fda::pca.fd(fd,nharm = nbasis)
    s <- list(list(data=NULL, coords=coords,coordsnames=NULL, 
                  data_fd = fd, fpca=fpca, variable_name= NULL, 
                  call_args=NULL))
    class(s) <- "SpatFD"
    return(s)
  }) -> SpatFD.sims
  
  return(SpatFD.sims)
  
}
