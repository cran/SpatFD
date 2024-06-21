ggmap_KS <-
function(KS, map_path=NULL, window_time = NULL, method = "lambda", map_n = 5000, zmin = NULL, zmax = NULL, graph = "plotly"){
  if (!is.null(map_path)){
    if(is.character(map_path)){
      map <- sf::st_read(map_path)
    }else{
      map = map_path
    }
  }else{
    mx <- min(KS$SFD[[1]]$coords[,1])
    Mx <- max(KS$SFD[[1]]$coords[,1])
    my <- min(KS$SFD[[1]]$coords[,2])
    My <- max(KS$SFD[[1]]$coords[,2])
    map <- sf::st_polygon(list(
    matrix(c(mx,my,Mx,my,Mx,My,mx,My,mx,my),byrow = TRUE,ncol = 2)),
    )
  }

  newcoords <- sf::st_sample(map, map_n, type = "regular")
  newcoords <- sf::st_coordinates(newcoords)
  colnames(newcoords) <- colnames(KS$SFD[[1]]$coords)
  
  if(inherits(KS,"KS_pred")){
    KS_SFD <- SpatFD::KS_scores_lambdas(KS$SFD, newcoords, model = KS$model, method = method, name = KS$name)
    SFDl <- list(SpatFD::recons_fd(KS_SFD,KS$name))
  }
  if(inherits(KS,"COKS_pred")){
    KS_SFD <- SpatFD::COKS_scores_lambdas(KS$SFD, newcoords, model = KS$model, method = method)
    SFDl <- list()
    for (k in 1:length(KS$SFD)){SFDl[[k]] <- SpatFD::recons_fd(KS_SFD,k)}
  }
  
  grafl <- list()
  for (k in 1:length(SFDl)){
  SFD <- SFDl[[k]]  
  namek <- names(KS$SFD)[k]
  if(is.null(window_time)) {
    times <- SFD$basis$rangeval[1]
  } else if (!(all(window_time >= SFD$basis$rangeval[1]) && all(window_time <= SFD$basis$rangeval[2]))) {
    stop(paste("window_time is out of bounds: Must be some value(s) between ", SFD$basis$rangeval[1], "and ",SFD$basis$rangeval[2]))
  }  else {
    times <- sort(window_time)
  }

  eval <- fda::eval.fd(times, SFD)

  melt_s <- data.frame(Time = times[1],Value = t(eval)[,1],
             X = newcoords[,1],Y = newcoords[,2])
  if (length(times) > 1){
  for (t in 2:length(times)){
    melt_s <- rbind(melt_s,data.frame(Time = times[t],Value = t(eval)[,t],
                         X = newcoords[,1],Y = newcoords[,2]))
  }
  }
  graf <- list()
  if(is.null(zmin)){zminl = min(melt_s$Value)}else{zminl <- zmin}
  if(is.null(zmax)){zmaxl = max(melt_s$Value)}else{zmaxl <- zmax}

  for(i in 1:length(times)){

    melt_s_2 <- melt_s[melt_s$Time == times[i],]

    if (graph == 'plotly'){
    graf[[i]] <- dplyr::`%>%`(plotly::plot_ly(
      x = melt_s_2$X,
      y = melt_s_2$Y,
      z = melt_s_2$Value,
      type = "heatmap",
      colorbar = list(title = "Prediction"),
      reversescale = TRUE,
      zmin = zminl,
      zmax = zmaxl
    ),
      plotly::layout(
        title = paste(namek,"- Prediction - Time = ", times[i]),
        xaxis = list(showticklabels = FALSE), yaxis = list(showticklabels = FALSE),
        scene = list(aspectration = list(x = 1, y = 1))
      ))
    }
    if (graph == 'gg'){
      graf[[i]] <- ggplot2::ggplot(data = melt_s_2,
                                   ggplot2::aes_(x = ~X,
                                       y = ~Y))+
        ggplot2::geom_tile(ggplot2::aes(fill = ~Value))+
        ggplot2::labs(fill = "Prediction",title = paste("Prediction - Time = ", times[i]),
                      x = '',y = '',color = NULL,lwd = NULL,subtitle = namek)+
        ggplot2::scale_fill_viridis_c(direction = -1,limits = c(zminl,zmaxl)) +
        ggplot2::coord_fixed() +
        ggplot2::theme(plot.background = ggplot2::element_blank(),
                       panel.grid.major = ggplot2::element_blank(),
                       panel.grid.minor = ggplot2::element_blank(),
                       panel.border = ggplot2::element_blank(),
                       axis.line = ggplot2::element_blank(),
                       axis.text = ggplot2::element_blank())
    }

  }
  grafl[[k]] <- graf
  }
  names(grafl) <- names(KS$SFD)
  if(length(SFDl) == 1){grafl <- grafl[[1]]}
  return(grafl)

}
