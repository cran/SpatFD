print.OptimalSpatialDesign <- function(x, ...){
  OSD <- x
  if( is.null(OSD$fixed_stations) ){
    n_fix <- 0
  }else{
    n_fix <- nrow(OSD$fixed_stations)
  }
  n_new <- nrow(OSD$new_stations)
  cat("Optimal Spatial Design\n----------------------\n  Fixed Stations:",n_fix,
      "\n  New Stations:",n_new,
      "\n  New Coordinates:\n")
  if(n_new>6){
    print(utils::head(OSD$new_stations,6))
    cat("\n" )
  }else{
    print(OSD$new_stations)
  }
}
summary.SpatFD <- function(object, ...){
  SpatFD = object
  i=1
  for (i in 1:length(SpatFD)){
    var = SpatFD[[i]]$variable_name
    df = SpatFD[[i]]$data
    coor = SpatFD[[i]]$coords
    ev = SpatFD[[i]]$fpca$values
    meanfd = SpatFD[[i]]$fpca$meanfd
    varprop = SpatFD[[i]]$fpca$varprop

    cat("# ",var,"\n")

    cat("## Data","\n")
    print(rbind(utils::head(df, 4),
                rep("...", times=dim(df)[2]),
                utils::tail(df, 4)))

    cat("\n","## Coordinates","\n")
    print(rbind(utils::head(coor,4),
                rep("...", times=dim(coor)[2])))

    cat("\n","## Eigenvalues","\n")
    print(rbind(utils::head(data.frame(ev),4),
                "..."))

    cat("\n","## Mean coefficients","\n")
    print(rbind(utils::head(data.frame(meanfd$coefs), 4),
                "...",
                utils::tail(data.frame(meanfd$coefs),4)))

  cat("\n","## Proportion of explained variance by component","\n")
  print(rbind(utils::head(data.frame(varprop))))
  cat("\n","\n")

  i=i+1
  }
}
summary.KS_pred <- function(object, ...){
  SpatFD = object
  if (is.null(SpatFD$KS_scores)&&!is.null(SpatFD$KS_lambda)){
    lambda_pred = SpatFD$KS_lambda$lambda_pred
    lambda_varpred = SpatFD$KS_lambda$lambda_varpred
    model = SpatFD$model

    cat("\n","## Lambda values","\n")
    print(lambda_pred)

    cat("\n","## Lambda var_predicted","\n")
    print(lambda_varpred)

    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}
  }
  if (!is.null(SpatFD$KS_scores)&&is.null(SpatFD$KS_lambda)){
    scores_pred = SpatFD$KS_scores$scores_pred
    scores_varpred = SpatFD$KS_scores$scores_varpred
    model = SpatFD$model

    cat("\n","## Scores","\n")
    print(scores_pred)

    cat("\n","## Scores var_predicted","\n")
    print(scores_varpred)

    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}

  }
  if (!is.null(SpatFD$KS_scores)&&!is.null(SpatFD$KS_lambda)){
    scores_pred = SpatFD$KS_scores$scores_pred
    scores_varpred = SpatFD$KS_scores$scores_varpred
    lambda_pred = SpatFD$KS_lambda$lambda_pred
    lambda_varpred = SpatFD$KS_lambda$lambda_varpred
    model = SpatFD$model

    cat("\n","## Lambda values","\n")
    print(lambda_pred)

    cat("\n","## Lambda var_predicted","\n")
    print(lambda_varpred)

    cat("\n","## Scores","\n")
    print(scores_pred)

    cat("\n","## Scores var_predicted","\n")
    print(scores_varpred)

    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}
  }
}
summary.COKS_pred <- function(object, ...){
  SpatFD = object
  if (is.null(SpatFD$COKS_scores)&&!is.null(SpatFD$COKS_lambda)){
    lambda_pred = SpatFD$COKS_lambda$lambda_pred
    lambda_varpred = SpatFD$COKS_lambda$lambda_varpred
    model = SpatFD$model
    
    cat("\n","## Lambda values","\n")
    print(lambda_pred)
    
    cat("\n","## Lambda var_predicted","\n")
    print(lambda_varpred)
    
    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}
  }
  if (!is.null(SpatFD$COKS_scores)&&is.null(SpatFD$COKS_lambda)){
    scores_pred = SpatFD$COKS_scores$scores_pred
    scores_varpred = SpatFD$COKS_scores$scores_varpred
    model = SpatFD$model
    
    cat("\n","## Scores","\n")
    print(scores_pred)
    
    cat("\n","## Scores var_predicted","\n")
    print(scores_varpred)
    
    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}
    
  }
  if (!is.null(SpatFD$COKS_scores)&&!is.null(SpatFD$COKS_lambda)){
    scores_pred = SpatFD$COKS_scores$scores_pred
    scores_varpred = SpatFD$COKS_scores$scores_varpred
    lambda_pred = SpatFD$COKS_lambda$lambda_pred
    lambda_varpred = SpatFD$COKS_lambda$lambda_varpred
    model = SpatFD$model
    
    cat("\n","## Lambda values","\n")
    print(lambda_pred)
    
    cat("\n","## Lambda var_predicted","\n")
    print(lambda_varpred)
    
    cat("\n","## Scores","\n")
    print(scores_pred)
    
    cat("\n","## Scores var_predicted","\n")
    print(scores_varpred)
    
    cat("\n","## Models","\n")
    for (i in 1:length(model)){
      cat("The model ",i,"is: \n")
      print(model[[i]])}
  }
}

summary.gfdata <- function(object,...) {
  gfdata <- object
  for (i in seq_along(gfdata)) {
    data_list <- gfdata[[i]]$fpca
    meanfd <- lapply(data_list, function(x) x$meanfd$coefs)
    varprop <- lapply(data_list, function(x) x$varprop)
    coor = gfdata[[i]]$coords
    ev = lapply(data_list,function(x) x$values)
    cat("\n","## Coordinates","\n")
    print(rbind(utils::head(coor,4),"\n","..."))
    cat("\n","## Eigenvalues","\n")
    print(rbind(utils::head(data.frame(ev),4),
                "..."))
    cat("\n","## Mean coefficients:","\n")
    print(rbind(utils::head(data.frame(meanfd), 4),
                "...",
                utils::tail(data.frame(meanfd),4)))
    
    cat("\n","## Proportion of explained variance by component","\n")
    print(rbind(utils::head(data.frame(varprop))))
    cat("\n","\n")
  }
}

