recons_fd <-
function(X,name = NULL){
  if (is.null(name)){
    if ("name" %in% names(X)){
      name <- X$name
    }else{message('No name provided, first variable by default')
      name <- 1}
  }
  if (inherits(X,"KS_pred")|inherits(X,"COKS_pred")) {
    result <- list()
    if(any(grepl("scores",names(X)))) {
      sc <- grep("scores",names(X))
      if(inherits(X[[sc]],"scores_pred")) {
        # Scores
        a = SpatFD::scores(X[[sc]])
        if(inherits(a,'list')){a <- a[[name]]}
        mean_coef = X$SFD[[name]]$fpca$meanfd$coefs
        nr=nrow(a)
        mean_coef = matrix(rep(mean_coef,nr),ncol = nr)
        coef_scores = (X$SFD[[name]]$fpca$harmonics$coef %*% t(a)) + mean_coef
        result_scores = fda::fd(coef_scores, X$SFD[[name]]$fpca$harmonics$basis)
        result$fd_scores = result_scores
      }
    }
    if(any(grepl("lambda",names(X)))) {
      sc <- grep("lambda",names(X))
      # Lambdas
      b = as.matrix(X[[sc]]$lambda_pred)
      coef_lambda = (X$SFD[[name]]$data_fd$coefs %*% b)
      result_lambda = fda::fd(coef_lambda, X$SFD[[name]]$data_fd$basis)
      result$fd_lambda = result_lambda
    }
    if(length(result) == 1){result <- result[[1]]}
    return(result)
  }else {
    stop("Wrong class KS_pred or COKS_pred")
  }
}
