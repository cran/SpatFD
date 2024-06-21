FD_optimal_design <- function(k, s0, model, fixed_stations = NULL,
                              scalar = FALSE, nharm = NULL,
                              method = "lambda", grid = NULL,
                              map = NULL, plt = FALSE){
  # validation ----------------------------------------------
  
  if (missing(k))
    stop("Missing k.")
  
  if(missing(s0))
    stop("Missing s0.")
  
  if(missing(s0))
    stop("Missing Model.")
  
  if(is.null(grid) && is.null(map))
    stop("Missing grid and map, please give at leat one.")
  
  if(!is.null(fixed_stations) && (length(base::intersect(class(fixed_stations),c("matrix","array","data.frame","SpatialPoints","SpatFD"))) == 0))
    stop("fixed_stations must be of class matrix, array, data.frame, SpatialPoints or SpatFD.")
  
  if(!is.null(fixed_stations))
    fixed_stations <- as.matrix(as.data.frame(fixed_stations))
  
  if(!is.numeric(k) || length(k)!=1){
    stop("k must be a positive integer.")
  }else if(round(k) != k || k < 1){
    stop("k must be a positive integer.")
  }
  
  if(length(intersect(class(s0),c("matrix","array","data.frame","SpatialPoints"))) == 0){
    stop("s0 must be of class matrix, array, data.frame or SpatialPoints.")
  }
  
  s0 <- as.matrix(as.data.frame(s0))
  
  if(ncol(s0)!=2)
    stop("s0 must have two columns.")
  
  if(length(base::intersect(class(model),c("variogramModel","list"))) == 0)
    stop("model must be a object of class variogramModel from gstat package or a lists of models of class variogramModel.")
  
  if(scalar){
    nharm <- 1
    method <- "scores"
    if("list" %in% class(model) && length(model)>1){
      message("For scalar data only one model must be passed. The first one will be used.")
      model <- model[[1]]
    }
  }
  
  if("variogramModel" %in% class(model)){
    if(is.null(nharm)){
      message("As 'model' is a single variogramModel and 'nharm' is not specified, 'nharm' is set to 1.")
      nharm <- 1
    }else if(nharm>1){
      message("As 'model' is a single variogramModel it will be used for all the harmonics.")
    }
  }
  
  if("list" %in% class(model)){
    if(!all(sapply(model,function(v)"variogramModel" %in% class(v))))
      stop("Every element in model must be of class variogramModel.")
    if(is.null(nharm)){
      message("As 'nharm' is not specified, it will be set to the number of variogramModel objects in 'model'.")
      nharm <- length(model)
    }
    if(nharm != length(model)){
      message("As the number of variogramModel in 'model' object and 'nharm' are not the same, the first variogramModel will be used for all the harmonics.")
      model <- model[[1]]
    }
  }
  
  if(!(method %in% c("lambda","scores")))
    stop("method must be one of 'lambda' or 'scores'.")
  
  if(!is.null(grid) &&
     length(base::intersect(c("matrix","array","data.frame","SpatialPoints"), class(grid))) == 0)
    stop("grid must be of class SpatialPoints, matrix, array or data.frame.")
  
  if(!is.null(grid))
    grid <- as.matrix(as.data.frame(grid))
  
  if( (!is.null(grid)) && (ncol(grid)!=2))
    stop("grid must have two columns.")
  
  if(is.null(grid) && !(inherits(map,"Spatial")))
    stop("map must be an Spatial object from sp package such as Line, Lines, Polygon, SpatialPolygons, SpatialGrid or SpatialPixels.")
  
  
  
  # Basic objects
  if(is.null(grid)){
    suppressWarnings(
      grid <- as.data.frame(sp::spsample(map, n = 5e3,
                                         type = "regular"))
    )
  }
  
  G <- nrow(grid)
  
  stati0 <- grid[sample(x = 1:G,size = k),]
  stati0 <- as.matrix(stati0)
  
  if("variogramModel" %in% class(model)){
    tmp_list <- list()
    for(i in 1:nharm)
      tmp_list[[i]] <- model
    model <- tmp_list
  }
  
  
  if("SpatFD" %in% class(fixed_stations)){
    fixed_stations <- as.matrix(fixed_stations$coords)
  }else if(!is.null(fixed_stations)){
    fixed_stations <- as.matrix(as.data.frame(fixed_stations))
  }
  
  # Call optim
  stats::optim(par = c(stati0), fn = .vgm_model.fn,
               s0 = s0, model = model, method_i = method,
               grid = grid, fixed_stations = fixed_stations,
               method = "BFGS",
               control = list(
                 trace = 1L,
                 REPORT = 20L,
                 reltol = 1e-8,
                 maxit = 1000)
  ) -> result
  
  new_stati <- matrix(result$par,ncol=2)
  
  # Put the final result into the grid
  dist_tmp <- proxy::dist(new_stati,as.matrix(grid),diag = TRUE)
  ids_tmp <- apply(as.matrix(dist_tmp),1,which.min)
  new_stati <- matrix(c(as.matrix(grid)[ids_tmp,]),ncol = 2)
  colnames(new_stati) <- c("x","y")
  rownames(new_stati) <- rep("",nrow(new_stati))
  
  
  value <- list(new_stations = new_stati,
                fixed_stations = fixed_stations)
  
  # Plot -----------------------------------------
  if (plt){
    s0 <- as.data.frame(s0)
    
    if(is.null(map)){
      final_plot <- ggplot2::ggplot() +
        ggplot2::geom_point(ggplot2::aes(x = grid[,1],y = grid[,2]), colour = "gray90") + # grid
        ggplot2::geom_point(ggplot2::aes(x = s0[,1],y = s0[,2], col = "Target Points")) + # Target points
        ggplot2::geom_point(ggplot2::aes(x = new_stati[,1], y = new_stati[,2], col = " New Stations")) + # New stations
        {if(!is.null(fixed_stations))ggplot2::geom_point(ggplot2::aes(x = fixed_stations[,1], y = fixed_stations[,2], col = "Fixed Stations"))} + # Fixed stations
        ggplot2::theme_light() +
        ggplot2::labs(title = "Optimal Spatial Design",
                      subtitle = paste(k,"new stations"),
                      x = "x", y = "y") +
        ggplot2::theme(legend.title = ggplot2::element_blank()) +
        ggplot2::scale_color_discrete()
    } else {
      final_plot <- ggplot2::ggplot() +
        ggplot2::geom_point(ggplot2::aes(x = grid[,1],y = grid[,2]), colour = "gray90") + # grid
        ggplot2::geom_sf(data = sf::st_as_sf(map), fill = "#ffffff00", colour = "gray40") + # map
        ggplot2::geom_point(ggplot2::aes(x = s0[,1],y = s0[,2], col = "Target Points")) + # Target points
        ggplot2::geom_point(ggplot2::aes(x = new_stati[,1], y = new_stati[,2], col = "New Stations")) + # New stations
        {if(!is.null(fixed_stations))ggplot2::geom_point(ggplot2::aes(x = fixed_stations[,1], y = fixed_stations[,2], col = "Fixed Stations"))} + # Fixed stations
        ggplot2::theme_light() +
        ggplot2::labs(title = "Optimal Spatial Design",
                      subtitle = paste(k,"new stations"),
                      x = "Longitude", y = "Latitude") +
        ggplot2::theme(legend.title = ggplot2::element_blank())
    }
    
    value[["plot"]] <- final_plot
    
  }else{
    value[["plot"]] <- NULL
  }
  
  class(value) <- "OptimalSpatialDesign"
  return(value)
}