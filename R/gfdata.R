gfdata <- function(data, p, basis = "Bsplines", coords = NULL, nbasis = NULL, names = NULL, lambda = 0){
  
  if(!inherits(data, "matrix"))
    stop("'data' is not of class 'matrix'")
  
  # Validate coords
  if(!(is.matrix(coords) || is.data.frame(coords))){
    stop("Wrong class of coords object")
  } else if(!all(apply(coords, c(1,2), is.numeric))){
    stop("Coords must be numeric data")
  } else if(any(is.na(coords))){
    stop("There is some NA value in coords")
  }
  
  classes = levels(as.factor(data[, ncol(data)]))
  class_list = list()
  
  if(length(nbasis) == 1){
    nbasis = rep(nbasis, length(classes))
  }
  
  for (i in 1:length(classes)) {
    datos = subset(data[,-ncol(data)], data[, ncol(data)] == classes[i])
    num_rows = nrow(datos)
    
    if(num_rows %% p != 0)
      stop(paste("'p' is not a multiple of the number of rows in class", i))
    
    n = num_rows / p
    datos_split = split.data.frame(datos, rep(1:n, each = p))
    
    # Transpose each split to have dimensions [p, number of segments]
    datos_split = lapply(datos_split, t)
    
    # Create the basis functions
    rng = range(1:p)
    
    if (basis == "Bsplines") {
      basis_fd = fda::create.bspline.basis(rng, nbasis[i])
    } else if (basis == "fourier") {
      basis_fd = fda::create.fourier.basis(rng, nbasis[i])
    } else {
      stop("Unsupported basis type")
    }
    
    # Convert to functional data
    data_fd = lapply(datos_split, function(x) fda::smooth.basis(1:p, t(x), basis_fd)$fd)
    
    # PCA on functional data
    pca_result = lapply(data_fd, function(fd) fda::pca.fd(fd, nharm = min(10, ncol(fd$coefs))))
    
    class_list[[i]] = list(data = datos_split, coords = coords, data_fd = data_fd, fpca = pca_result)
  }
  
  names(class_list) = names
  class(class_list) = "gfdata"
  
  return(class_list)
}
