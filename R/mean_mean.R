mean_mean <- function(data.train.pca) {
  mean.classes <- vector("list", length(data.train.pca))
  names(mean.classes) <- names(data.train.pca)
  
  for (i in seq_along(data.train.pca)) {
    data.mean <- do.call(rbind, lapply(data.train.pca[[i]]$fpca, function(x) {
      mean.class <- x$meanfd
      eval <- fda::eval.fd(seq(1, mean.class$basis$rangeval[2]), mean.class)
      t(eval)
    }))
    
    mean.gfd <- fda.usc::fdata(data.mean)
    mean.v <- fda.usc::func.mean(mean.gfd)
    mean.classes[[i]] <- mean.v
  }
  
  return(mean.classes)
}
