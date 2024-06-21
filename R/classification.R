classification <- function(data.train.pca, new.basis, k, distance, mcov = NULL) {
  n <- length(data.train.pca)
  m <- length(data.train.pca[[1]]$data)
  coefs_dim <- dim(new.basis$coefs)[2]
  
  # Precompute new vectors for the entire dataset
  new_vectors <- array(0, dim = c(m, n, coefs_dim))
  for (i in seq_len(n)) {
    for (j in seq_len(m)) {
      new_vectors[j, i, ] <- vapply(seq_len(coefs_dim), function(k) fda::inprod(new.basis[k], data.train.pca[[i]]$fpca[[j]]$meanfd[1]), numeric(1))
    }
  }
  
  # Flatten scores into a matrix for efficient distance computation
  train_scores <- array(0, dim = c(m, n, coefs_dim))
  for (i in seq_len(n)) {
    for (j in seq_len(m)) {
      train_scores[j, i, ] <- data.train.pca[[i]]$fpca[[j]][["scores"]][, 1]
    }
  }
  
  # Function to compute pairwise distances between matrices
  pairwise_distance <- function(A, B, method, mcov = NULL) {
    if (method == "mahalanobis") {
      dists <- matrix(0, nrow = nrow(A), ncol = ncol(A))
      for (i in seq_len(ncol(A))) {
        dists[, i] <- stats::mahalanobis(A[, i, , drop = FALSE], B[, i, , drop = FALSE], mcov[[i]])
      }
      return(dists)
    } else {
      A <- matrix(A, nrow = nrow(A) * ncol(A))
      B <- matrix(B, nrow = nrow(B) * ncol(B))
      if (method == "euclidean") {
        return(matrix(sqrt(rowSums((A - B) ^ 2)), nrow = m))
      }
      if (method == "manhattan") {
        return(matrix(rowSums(abs(A - B)), nrow = m))
      }
      if (method == "cos_similarity") {
        A_norm <- sqrt(rowSums(A ^ 2))
        B_norm <- sqrt(rowSums(B ^ 2))
        return(matrix(1 - rowSums(A * B) / (A_norm * B_norm), nrow = m))
      }
      if (method == "minkowski") {
        return(matrix(rowSums(abs(A - B) ^ 1) ^ (1 / 1), nrow = m))
      }
    }
  }
  
  # Calculate distances
  mconf <- pairwise_distance(train_scores, new_vectors, distance, mcov)
  
  # Convert matrix to data frame and process
  mconf_df <- as.data.frame(mconf)
  colnames(mconf_df) <- paste0("Class", seq_len(n))
  mconf_long <- tidyr::pivot_longer(mconf_df, cols = tidyr::everything(), names_to = "Class")
  mconf_sorted <- mconf_long[order(mconf_long$value),]
  
  # Calculate class frequency
  class_freq <- table(mconf_sorted$Class[1:k])
  class_prob <- as.data.frame(class_freq / sum(class_freq))
  
  # Return the most frequent class
  return(as.character(class_prob[order(class_prob$Freq, decreasing = TRUE), ][1, 1]))
}
