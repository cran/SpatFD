mclass_data <- function(mean.mean, n.basis, type.basis = "bspline") {
  
  data.mvowelf <- data.frame()
  
  for (i in seq_len(length(mean.mean))) {
    # Extract the actual data vector from the nested structure
    data_vector <- as.numeric(mean.mean[[i]]$data)
    
    n <- length(data_vector)
    if (n <= 1) {
      stop("Each element in mean.mean must contain more than one value.")
    }
    
    rangeval <- c(1, n)
    
    if (type.basis == "bspline") {
      basis <- fda::create.bspline.basis(rangeval = rangeval, nbasis = n.basis[[i]])
    } else if (type.basis == "fourier") {
      basis <- fda::create.fourier.basis(rangeval = rangeval, nbasis = n.basis[[i]])
    } else {
      stop("Unsupported basis type")
    }
    
    mean.vow <- fda::Data2fd(argvals = seq(1, n), y = matrix(data_vector, nrow = n, ncol = 1), basisobj = basis)
    
    eval <- fda::eval.fd(seq(1, rangeval[2]), mean.vow)
    data.mvowel <- data.frame(x = seq(1, rangeval[2]), value = as.vector(eval), vowel = rep(names(mean.mean)[i], length(eval)))
    
    data.mvowelf <- rbind(data.mvowelf, data.mvowel)
  }
  
  data.mvowelf$vowel <- as.factor(data.mvowelf$vowel)
  
  return(data.mvowelf)
}
