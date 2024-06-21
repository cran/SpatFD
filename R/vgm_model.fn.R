.vgm_model.fn <- function(points, s0, model, method_i = "lambda", grid, fixed_stations){

  # Basic objects
  method <- method_i
  N <- nrow(s0) # Number of target points
  points <- matrix(points,ncol=2)

  # Replace points by their nearest in the given grid
  #D_toGrid <- proxy::dist(points,as.matrix(grid),diag = TRUE)
  #closests <- apply(as.matrix(D_toGrid),1,which.min)
  #points <- as.matrix(grid)[closests,]

  # Join all the stations
  points <- rbind(fixed_stations,points)
  colnames(points) <- c("x","y")
  # k <- length(points)/2
  k <- nrow(points) # Number of stations
  z <- rep.int(1,k)
  L <- length(model) # Number of harmonics
  df <- sp::SpatialPointsDataFrame(coords = points,
                                   data = as.data.frame(z))
  targetPoints <- sp::SpatialPoints(s0)

  # distance matrix
  dist_matrix <- as.matrix(proxy::dist(points,diag = TRUE))
  dist_s0 <- as.matrix(proxy::dist(points, s0,diag = TRUE))

  # ------------------ method lambda

  if (method == "lambda"){

    # Omega
    OMEGA <- lapply(model,function(m){
      gstat::variogramLine(object = m, dist_vector = dist_matrix, covariance = TRUE)
    })
    omega <- Reduce('+',OMEGA)

    # Vector c (\varsigma)
    C_VEC <- lapply(model,function(m){
      gstat::variogramLine(object = m, dist_vector = dist_s0, covariance = TRUE)
    })
    c_vec <- Reduce('+',C_VEC)

    # Expresión a maximizar
    accuracy <- sum(diag(t(c_vec)%*%solve(omega)%*%c_vec))

    return(-accuracy)
  }

  # ------------------ method scores

  if (method == "scores"){

    VARIANCES <- lapply(model,function(m){
      invisible(utils::capture.output(
        # kriging
        gstat::krige(
          formula = z~1,
          locations = df,
          newdata = targetPoints,
          beta = 0,
          model = m
        ) -> kr
      ))

      return(sum(kr$var1.var)) # return sum of variances

    })

    tot_variance <- Reduce('+',VARIANCES)

    return(tot_variance)
  }

}
