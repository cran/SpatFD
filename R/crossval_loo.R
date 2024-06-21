crossval_loo = function(object,plot_show=TRUE){
  
  # validation -------------------------------------------------------------
  if(!inherits(object,"KS_pred")){
    stop("input object must be KS_pred")
  }
  
  # object ----------------------------------------------------------------
  SFD_main = object$SFD
  KS_main = object
  args_SFD = SFD_main[[1]]$call_args
  
  data = args_SFD$data
  data_names=names(data)
  coord = args_SFD$coords
  n = ncol(data) 
  
  residual_norm_lambda = rep(NA,n)
  residual_norm_scores = rep(NA,n)
  # iteration on method both ------------------------------------------------
  if (!is.null(KS_main$KS_scores)&&!is.null(KS_main$KS_lambda)){
    for (i in 1:n){
 
      new_coord_i = coord[i,]
      data_i = data[,-i]
      coord_i = coord[-i,]
      
      suppressWarnings({
        SFD_i = CrossSpatFD(data_i,coord_i,SFD_main[[1]]$data_fd$basis,
            nharm=args_SFD$nharm,lambda = args_SFD$lambda)
        
        KS_i_lambda = suppressMessages(KS_scores_lambdas(
          SFD_i, 
          new_coord_i, 
          method = "lambda", 
          model = object$model))
        KS_i_scores = suppressMessages(KS_scores_lambdas(
          SFD_i, 
          new_coord_i, 
          method = "scores", 
          model = object$model))
        predict_i_lambda = recons_fd(KS_i_lambda)
        predict_i_scores = recons_fd(KS_i_scores)
      })
      
      residual_norm_lambda[i]=sqrt(fda::inprod(SFD_main[[1]]$data_fd[i]-predict_i_lambda,SFD_main[[1]]$data_fd[i]-predict_i_lambda,rng=c(1,nrow(data))))
      residual_norm_scores[i]=sqrt(fda::inprod(SFD_main[[1]]$data_fd[i]-predict_i_scores,SFD_main[[1]]$data_fd[i]-predict_i_scores,rng=c(1,nrow(data))))
      if(plot_show){
        plot(SFD_main[[1]]$data_fd[i], las=2)
        plot(predict_i_lambda, ann=FALSE, axes=FALSE,col=2)
        plot(predict_i_scores, ann=FALSE, axes=FALSE,col=3)
        legend("topleft", legend = c("KS lambda", "KS scores", data_names[i]), col = c("red","green" ,"black"), lty = 1)
        readline(prompt = "Press [Enter] to continue...")
        
      }
     
    }
  }
  
  # iteration on method lambda ------------------------------------------------
  if (is.null(KS_main$KS_scores)&&!is.null(KS_main$KS_lambda)){
    for (i in 1:n){
      
      new_coord_i = coord[i,]
      data_i = data[,-i]
      coord_i = coord[-i,]
      
      suppressWarnings({
        SFD_i = CrossSpatFD(data_i,coord_i,SFD_main[[1]]$data_fd$basis,
            nharm=args_SFD$nharm,lambda = args_SFD$lambda)
        KS_i_lambda = suppressMessages(KS_scores_lambdas(
          SFD_i, 
          new_coord_i, 
          method = "lambda", 
          model = object$model))
        predict_i_lambda = recons_fd(KS_i_lambda)
      })
      
      residual_norm_lambda[i]=sqrt(fda::inprod(SFD_main[[1]]$data_fd[i]-predict_i_lambda,SFD_main[[1]]$data_fd[i]-predict_i_lambda,rng=c(1,nrow(data))))
      
      if(plot_show){
      
        plot(SFD_main[[1]]$data_fd[i], las=2)
        plot(predict_i_lambda, ann=FALSE, axes=FALSE,col=2)
        legend("topleft", legend = c("KS lambda", data_names[i]), col = c("red", "black"), lty = 1)
        readline(prompt = "Press [Enter] to continue...")
      }
    }
  }
  
  # iteration on method scores ------------------------------------------------
  if (!is.null(KS_main$KS_scores)&&is.null(KS_main$KS_lambda)){
    for (i in 1:n){
      
      new_coord_i = coord[i,]
      data_i = data[,-i]
      coord_i = coord[-i,]
      
      suppressWarnings({
        SFD_i = CrossSpatFD(data_i,coord_i,SFD_main[[1]]$data_fd$basis,
            nharm=args_SFD$nharm,lambda = args_SFD$lambda)
        
        KS_i_scores = suppressMessages(KS_scores_lambdas(
          SFD_i, 
          new_coord_i, 
          method = "scores", 
          model = object$model))
        predict_i_scores = recons_fd(KS_i_scores)
      })
      
      residual_norm_scores[i]=sqrt(fda::inprod(SFD_main[[1]]$data_fd[i]-predict_i_scores,SFD_main[[1]]$data_fd[i]-predict_i_scores,rng=c(1,nrow(data))))
      
      if(plot_show){
        plot(SFD_main[[1]]$data_fd[i], las=2)
        plot(predict_i_scores, ann=FALSE, axes=FALSE,col=3)
        legend("topleft", legend = c("KS scores", data_names[i]), col = c("green", "black"), lty = 1)
        readline(prompt = "Press [Enter] to continue...")
      }
    }
  }
  
  # output of mean residual norm ----------------------------------------------
  message("## Mean Residual Norm","\n")
  message(paste0("lambda method: ", mean(residual_norm_lambda),"<---\n"))
  message(paste0("scores method: ", mean(residual_norm_scores),"<---\n"))
  return(list(lambda = residual_norm_lambda,scores = residual_norm_scores))
}
