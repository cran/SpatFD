gfd_clasif_data <- function(gfd_data, prop.train, seed = NULL) {
  # Prepare lists to hold the training and testing data
  gfd_train <- vector("list", length(gfd_data))
  gfd_test <- vector("list", length(gfd_data))
  
  if (!is.null(seed)) {
    set.seed(seed)
  }
  
  # Loop through each class in the data
  for (i in seq_along(gfd_data)) {
    # Assuming all elements in gfd_data[[i]] have the same length
    ntrial <- length(gfd_data[[i]]$data_fd)
    indices <- sample(ntrial, size = round(ntrial * prop.train))
    
    # Create copies of the current class data to preserve other elements
    train_class_data <- gfd_data[[i]]
    test_class_data <- gfd_data[[i]]
    
    # Update all relevant lists with the same indices
    train_class_data$data <- gfd_data[[i]]$data[indices]
    train_class_data$data_fd <- gfd_data[[i]]$data_fd[indices]
    train_class_data$fpca <- gfd_data[[i]]$fpca[indices]
    
    test_class_data$data <- gfd_data[[i]]$data[-indices]
    test_class_data$data_fd <- gfd_data[[i]]$data_fd[-indices]
    test_class_data$fpca <- gfd_data[[i]]$fpca[-indices]
    
    # Assign the modified class data to the train and test lists
    gfd_train[[i]] <- train_class_data
    gfd_test[[i]] <- test_class_data
  }
  
  names(gfd_train) <- names(gfd_data)
  names(gfd_test) <- names(gfd_data)
  
  # Combine the training and testing lists into one list with named elements
  list(train = gfd_train, test = gfd_test)
}
