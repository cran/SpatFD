COK_crossval_loo = function(object,plot_show=TRUE,var =1,show_all=FALSE){
  
  # validation -------------------------------------------------------------
  if(!inherits(object,"COKS_pred")){
    stop("input object must be COKS_pred")
  }
  
  # object ----------------------------------------------------------------
  SFD_main = object$SFD     
  KS_main = object  
  args_SFD <- NULL
  data <- NULL
  coord <- NULL
  unique_coords <- NULL
  n <- ncol(SFD_main[[var]]$data)
  filtered <- NULL
  residual_norm_scores = rep(NA,n)
  name = names(SFD_main)[var]
  data_names = names(SFD_main[[var]]$call_args$data)

  for (i in 1:length(SFD_main)){
    args_SFD[[i]] = SFD_main[[i]]$call_args
    data[[i]] <- args_SFD[[i]]$data
    coord[[i]] = args_SFD[[i]]$coords
    unique_coords <- unique(rbind(args_SFD[[i]]$coords,unique_coords))
  }
  
  # iteration on method scores ---------------------------------------------
  for(j in 1:nrow(unique_coords)){
    exclude <- unique_coords[j,]
    SFD_i <- NULL
    for(i in 1:length(SFD_main)){
      index <- which(SFD_main[[i]]$coords==c(exclude))[1]
      if(is.na(index)){
        newdata_i <-SFD_main[[i]]$data
        newcoords_i<-SFD_main[[i]]$coords
      }
      else{
        newdata_i <-SFD_main[[i]]$data[,-index]
        newcoords_i<-SFD_main[[i]]$coords[-index,]
      }
      SFD_i = CrossSpatFD(newdata_i,newcoords_i,SFD_main[[i]]$data_fd$basis,
                          nharm=SFD_main[[i]]$call_args$nharm,
                          lambda = SFD_main[[i]]$call_args$lambda,add = SFD_i,name = names(SFD_main)[i])
    }
    KS_i_scores =suppressMessages(COKS_scores_lambdas(
      SFD_i, 
      exclude, 
      method = "scores", 
      model = object$model))

    predict_i_scores = recons_fd(KS_i_scores,name=name)
    residual_norm_scores[j]=sqrt(fda::inprod(SFD_main[[var]]$data_fd[i]-predict_i_scores,SFD_main[[var]]$data_fd[i]-predict_i_scores,rng=c(1,nrow(SFD_main[[var]]$data))))

    if(plot_show){
      plot(SFD_main[[1]]$data_fd[i], las=2)
      plot(predict_i_scores, ann=FALSE, axes=FALSE,col=3)
      legend("topleft", legend = c("COK scores", rownames(exclude)), col = c("green", "black"), lty = 1)
      if(show_all==FALSE){
        readline(prompt = "Press [Enter] to continue...")
      }
    }

  }
message(paste0("scores method: ", mean(residual_norm_scores),"<---\n"))
return(residual_norm_scores)
}