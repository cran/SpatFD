KS_scores_lambdas <-
function(SFD, newcoords, model, method = "lambda", name=NULL,fill.all=NULL){

  # Validation --------------------------------------------------------------

  #all
  if(missing(SFD)){
    stop("Missing SFD")
  }
  if (missing(newcoords)){
    stop("Missing new coords")
  }
  if(missing(model)){
    stop("Missing model")
  }
  #SFD
  if(!inherits(SFD,"SpatFD")){
    stop("SFD must be an object SpatFD")
  }

  #newcoords
  if(!(is.matrix(newcoords) || is.data.frame(newcoords))){
    stop("Wrong class of newcoords object")
  }else if(!all(apply(newcoords, c(1,2), is.numeric))){
    stop("Newcoords must be numeric data")
  }else if(any(is.na(newcoords))){
    stop("There is some NA value in newcoords")
  }

  # messages default values
  if(missing(name)){
    message("Using first variable by default")
  }
  if(missing(fill.all)){
    message("Using fill.all = TRUE by default")
  }
  if(missing(method)){
    message("Using method = 'lambda' by default")
  }

  #method
  if (!(is.character(method) && length(method)==1)){
    stop("Wrong class of method object")
  } else if (!(method=="lambda" || method =="scores" || method == "both")){
    stop("method must be one of the following: 'lambda', 'scores' or 'both'")
  }

  #name
  if(is.null(name)){
    name=1
  } else if ((is.character(name)&& length(name)==1)){
    if (length(which(names(SFD)==name))==1){
      name=which(names(SFD)==name)
    }else if (length(which(names(SFD)==name))==0){
      stop(paste(name,"doesn't not exists. Change name for an existing variable name."))
    }else if (length(which(names(SFD)==name))==0){
      stop("There are more than one variable with the same name")
    }
  }
  if ((is.null(name)  || !(is.numeric(name)&& length(name)==1))){
    stop("Wrong class of name object")
  }

  #fill.all
  if(is.null(fill.all)){
    fill.all=TRUE
  }else if ( !( ( isTRUE(fill.all) || isFALSE(fill.all) ) && length(fill.all)==1 ) ){
    stop("Wrong class of fill.all object")
  }


  #model
  if(!(inherits(model,"variogramModel") || inherits(model,"list"))){
    stop("Wrong class of model, model should be of class variogramModel or a list of them (use vgm of gstat package) ")
  }else if(inherits(model,"list") && !all(sapply(model,inherits,"variogramModel"))){
    stop("Wrong class of model, each element of list should be of class variogramModel (use vgm of gstat package)")
  }else if(inherits(model,"list") && (length(model)!=ncol(as.data.frame(SFD[[name]]$fpca$scores)))){
    stop("length of list of models must be equal to number of harmonics of the choosen variable ")
  }else if(inherits(model,"variogramModel") && !(fill.all || (ncol(as.data.frame(SFD[[name]]$fpca$scores))==1))){
    stop("If model is not a list and there are more than one nharm of that variable, then fill.all must be TRUE or you can create a list of models with the same number of harmonics")
  }


  # Kriging -----------------------------------------------------------------
  #scores
  puntaje=SFD[[name]]$fpca$scores
  rownames(puntaje)=SFD[[name]]$coordsnames
  puntajes=as.data.frame(puntaje)
  sp::coordinates(puntajes)=SFD[[name]]$coords

  if ("numeric" %in% class(newcoords)){
    newcoords= matrix(newcoords, nrow = length(newcoords))}
  if ("matrix" %in% class(newcoords)){
    newcoords=as.data.frame(newcoords)}
  coords_name=colnames(newcoords)
  newcoords=stats::setNames(newcoords, c("X", "Y"))
  
                                   # Method 1 #

  if(method == "lambda" || method == "both"){
    matdis = as.matrix(stats::dist(SFD[[name]]$coords))
    matdis_pred = as.matrix(stats::dist(rbind(SFD[[name]]$coords, as.data.frame(newcoords))))[(nrow(matdis)+1):(nrow(matdis)+nrow(newcoords)), 1:nrow(matdis)]

    if(nrow(newcoords) == 1){
      matdis_pred <- t(as.matrix(matdis_pred))
    }

    # Omega
    omegas <- list()
    omega <- matrix(0, nrow = nrow(matdis), ncol = ncol(matdis))
    for(i in 1:ncol(puntajes)){

      omegas[[i]] = gstat::variogramLine( model[[i]], dist_vector = matdis, covariance = TRUE)
      omega = omega + omegas[[i]]
    }

    # C
    vectores_c <- list()
    vector_c = matrix(0, ncol = nrow(matdis), nrow = nrow(matdis_pred))

    for(i in 1:ncol(puntajes)){

      vectores_c[[i]] = gstat::variogramLine( model[[i]], dist_vector = matdis_pred, covariance = TRUE)
      vector_c = vector_c + vectores_c[[i]]
    }

    # Lambda
    lambda <- solve(omega) %*% t(vector_c)
    lambda_data = as.data.frame(lambda)
    colnames(lambda_data) = rownames(newcoords)
    rownames(lambda_data) = SFD[[name]]$coordsnames

    # Var
    lambda_var <- list()
    for(i in 1:ncol(puntajes)){

      lambda_var[[i]] <- SFD[[name]]$fpca$values[i] - 2*(vectores_c[[i]] %*% lambda) + t(lambda) %*% (omegas[[i]]) %*% lambda
    }

    # Var data
    lambda_var_data <- matrix(0, nrow = nrow(newcoords), ncol = ncol(puntajes))
    for(i in 1:ncol(puntajes)){

      for(j in 1:nrow(newcoords)){
        lambda_var_data[j, i] <- lambda_var[[i]][j,j]
      }
    }
    lambda_var_data = data.frame(lambda_var_data, "VTotal" = rowSums(lambda_var_data))
    rownames(lambda_var_data)=rownames(newcoords)

    out_lambda=list(lambda_pred = lambda_data, lambda_varpred = lambda_var_data, 
                    omega = omega)
    class(out_lambda)="lambda_pred"
  }

                                     # Method 2 #

  if(method == "scores" || method == "both") {
    colnames(newcoords)=c('x','y')
    sp::coordinates(newcoords)=~x+y
    #kriging
    K=list()
    for (i in 1:ncol(puntajes)){
      K[[i]] <- suppressWarnings(gstat::krige(puntajes[[i]]~1,puntajes,newcoords, model = model[[i]],
                             beta = 0))
    }

    #prediction
    pred=K[[1]]$var1.pred
    if(ncol(puntajes)>1){
      for (i in 2:ncol(puntajes)){
        pred=cbind(pred,K[[i]]$var1.pred)
      }
    }
    pred=as.data.frame(pred)
    colnames(pred)[1]="V1"
    rownames(pred)=rownames(newcoords)

    #variance
    varpred=K[[1]]$var1.var
    if(ncol(puntajes)>1){
      for (i in 2:ncol(puntajes)){
        varpred=cbind(varpred,K[[i]]$var1.var)
      }
    }
    varpred=data.frame(varpred, "VTotal" = rowSums(varpred))
    colnames(varpred)[1]="V1"
    rownames(varpred)=rownames(newcoords)

    out_scores=list(scores_pred = pred, scores_varpred = varpred)
    class(out_scores)="scores_pred"
  }
  
  #Output
  if(method == "both"){
    out <- list(SFD=SFD, KS_scores = out_scores, KS_lambda = out_lambda, model = model, name=name)
  } else if (method == "lambda"){
    out <- list(SFD=SFD, KS_lambda = out_lambda,  model = model, name=name)
  } else {
    out <- list(SFD=SFD, KS_scores = out_scores,  model = model, name=name)
  }
  class(out)="KS_pred"
  return(out)
}
