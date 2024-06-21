COKS_scores_lambdas <- 
  function(SFD, newcoords, model, method = "scores", fill.all=TRUE){
  #----------------------------------------------------------------------------
  #           VALIDANDO ARGUMENTOS *
  #----------------------------------------------------------------------------
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
  if(!inherits(SFD,"SpatFD") & !inherits(SFD,"CrossSpatFD")){
    stop("SFD must be an object SpatFD")
  }
  if(length(SFD) == 1){
    stop("SFD must have more than one variable in order to perform cokriging")
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
  
  #fill.all
  if ( !( ( isTRUE(fill.all) || isFALSE(fill.all) ) && length(fill.all)==1 ) ){
    stop("Wrong class of fill.all object")
  }

  #model
  if(!(inherits(model,"variogramModel") || inherits(model,"list"))){
    stop("Wrong class of model, model should be of class variogramModel or a list of them (use vgm of gstat package) ")
  }else if(inherits(model,"list") && !all(lapply(model,inherits,"variogramModel"))){
    stop("Wrong class of model, each element of list should be of class variogramModel (use vgm of gstat package)")
  }

  puntaje <- list()
  puntajes <- list()
  for(k in 1:length(SFD)){
    puntaje[[k]] <- SFD[[k]]$fpca$scores
    rownames(puntaje[[k]]) <- SFD[[k]]$coordsname
    puntajes[[k]] <- as.data.frame(puntaje[[k]])
    sp::coordinates(puntajes[[k]]) <- SFD[[k]]$coords
  }

  if ("numeric" %in% class(newcoords)){
    newcoords= matrix(newcoords, nrow = length(newcoords))}
  if ("matrix" %in% class(newcoords)){
    newcoords=as.data.frame(newcoords)}
  colnames(newcoords) <- c('x','y')
  sp::coordinates(newcoords) <- ~x+y
  
  out_lambda <- NULL
  
  if(method == "scores" || method == "both") {
  aa <- rep(1:length(SFD),lapply(puntajes,ncol))
  bb <- unlist(lapply(lapply(puntajes,ncol),seq))
  cc <- paste0(
    c("g = gstat::gstat(,paste(colnames(SFD[[",
      rep("g = gstat::gstat(g,paste(colnames(SFD[[",(length(aa)-1))),
    aa,
    rep("]][[\"fpca\"]][[\"harmonics\"]][[\"coefs\"]])[",length(aa)),
    bb,
    rep("],",length(aa)),
    aa,
    rep(",sep=\".\"),puntajes[[",length(aa)),
    aa,
    rep("]][[",length(aa)),
    bb,
    rep("]]~1,puntajes[[",length(aa)),
    aa,
    rep("]])",length(aa))
  )

  eval(parse(text=cc))
  g <- gstat::gstat(g, model=model, fill.all=fill.all)
  vg <- gstat::variogram(g)
  mcl <- gstat::fit.lmc(vg, g, fit.method=6,correct.diagonal=1.01)
  print(plot(vg, model = mcl))
  z <- stats::predict(mcl, newdata = newcoords)
  
  coordn <- as.data.frame(z)[,c(1,2)]
  z <- as.data.frame(z)[,-c(1,2)]
  preds <- z[grepl('pred',names(z))]
  vars <- z[grepl('var',names(z))]
  pred = varpred <- list()
  p1 <- ncol(puntajes[[1]])
  pred[[1]] <- as.data.frame(preds[1:p1])
  varpred[[1]] <- as.data.frame(vars[1:p1])
  cum <- p1
  if (length(SFD) > 1){
  for(i in 2:length(SFD)){
    pn <- ncol(puntajes[[i]])
    pred[[i]] <- as.data.frame(preds[(cum+1):(cum+pn)])
    varpred[[i]] <- as.data.frame(vars[(cum+1):(cum+pn)])
    cum <- cum + pn
  }
  }
  names(pred) = names(varpred) <- names(SFD)
  out_scores <- list(scores_pred = pred, scores_varpred = varpred)
  class(out_scores) <- "scores_pred"
  }
  
  if(method == "both"){
    out <- list(SFD=SFD,COKS_scores=out_scores, COKS_lambda = out_lambda, model = model,modelfit = mcl)
  } else if (method == "lambda"){
    out <- list(SFD=SFD,COKS_lambda = out_lambda, model = model,modelfit = mcl)
  } else {
    out <- list(SFD=SFD,COKS_scores=out_scores, model = model,modelfit = mcl)
  }
  class(out) = "COKS_pred"
  return(out)
}
