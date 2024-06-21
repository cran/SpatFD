generate_basis <- function(basis = "Fourier",n_functions = 10,
                           L = NULL,fda_basis = NULL){
  
  # Validating arguments ----
  
  ## basis ----
  if(!is.character(basis)) stop("basis must be 'Fourier' of 'Legendre'.")
  
  if(!(basis %in% c("Fourier","Legendre"))) stop("basis must be 'Fourier' of 'Legendre'.")
  
  ## n_functions ----
  if(!is.numeric(n_functions)) stop("n_functions must be a positive integer.")
  
  if(n_functions<1) stop("n_functions must be a positive integer.")
  
  n_functions <- floor(n_functions)
  
  ## L ----
  if(basis == "Legendre"){
    if(!is.null(L)){
      message("L argument is for 'Fourier' basis, thus will be ignored.")
    }
    L <- 1
  }
  
  if(is.null(L) & (basis == "Fourier")){
    L <- 1
    message("As L is not passed, it will be set to 1.")
  }
  
  ## fda_basis ----
  if(!is.null(fda_basis)){
    if(!inherits(fda_basis,"basisfd"))
      stop("fda_basis must be a 'basisfd' object.")
  
    fda_basis_range <- fda_basis$rangeval
    if((fda_basis_range[1] < (-L)) | (fda_basis_range[2] > L))
      message('fda_basis range does not fall in basis range. The interval [-L,L] (or [-1,1] if basis is Legendre) must contain the domain of the mean function that is passed to sin_functional_process.')
  }
  
  
  if(basis == "Fourier")
    if((L<0) | !is.numeric(L))
    stop("L must be a positive value.")
  
  
  # generator function ----
  if(basis == "Fourier"){
    seno_fourier=function(x,n,L){sqrt(2/L)*sin(n*pi*x/L)}
    coseno_fourier=function(x,n,L){sqrt(2/L)*cos(n*pi*x/L)}
    f_gen <- function(x,n){
      # Re( (2*pi)^(-1/2)*exp(1i*n*x) )
      if((n%%2) == 0){
        seno_fourier(x,n/2,L)
      }else{
        coseno_fourier(x,n/2 + .5,L)
      }
    }
  }else{
    f_gen <- function(x,n){
      deriv_term <- .DD(expression((x^2 - 1)^n),'x',order = n)
      1/(2^n*factorial(n)) * eval(deriv_term)
    }
  }
  
  # Domain ----
  x_seq <- seq(-L,L,length = 500)
  
  # Evaluate ----
  values <- matrix(NA,500,n_functions)
  for(k in 1:n_functions){
    values[,k] <- f_gen(x_seq,k)
  }
  
  
  # df object ----
  
  ## fda basis ----
  if(is.null(fda_basis)){
    if(basis == "Fourier"){
      fda::create.bspline.basis(
        rangeval = c(-L,L),
        nbasis = 40,
        norder = 4) -> fda_basis
    }else{
      fda::create.fourier.basis(
        rangeval = c(-L,L),
        nbasis = 40
      ) -> fda_basis
    }
  }
  
  ## lambda optimization ----
  Lfd_obj <- fda::int2Lfd(m = 2)
  GCV.bsp <- NULL
  log_lambdas <- -40:4
  for (k in log_lambdas){
    lambda <- exp(k)
    mi.fdPar <- fda::fdPar(fda_basis, Lfd_obj, lambda = lambda)
    mi.fd <- fda::smooth.basis(argvals = x_seq,
                          y = values, fdParobj = mi.fdPar)
    GCV.bsp <- c(GCV.bsp,sum(mi.fd$gcv,na.rm=TRUE))
  }
  
  log_lam <- log_lambdas[which.min(GCV.bsp)]
  
  ## Create object ----
  mi.fdPar <- fda::fdPar(fda_basis, Lfd_obj, lambda = exp(log_lam))
  
  
  if(basis == "Legendre"){
    fun_names <- paste0('P',1:n_functions)
  }else{
    fun_names <- c(outer(c('sin','cos'),1:n_functions,paste0))[1:n_functions]
  }
  fdnames <- list(
    'time' = x_seq,
    'reps' = fun_names,
    'values' = 'value'
  )
  
  mi.fd <- fda::smooth.basis(argvals = x_seq,
                        y = values, 
                        fdParobj = mi.fdPar,
                        fdnames = fdnames)
  
  return(mi.fd$fd)
  
  
}
