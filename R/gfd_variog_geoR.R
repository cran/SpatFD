gfd_variog_geoR <- function(gfd_pca_Data, pairsmin = 2) {
  coord = lapply(gfd_pca_Data,function(x) x$coord)
  scores <- list()
  dataframe <- list()
  geodata.f1 <- list()
  geodata.f2 <- list()
  variog.f1 <- list()
  variog.f2 <- list()
  
  for (i in seq_along(gfd_pca_Data)) {
    # Extraer los puntajes
    scores[[i]] <- lapply(gfd_pca_Data[[i]]$fpca, function(x) x$scores)
    
    # Crear dataframes combinando los puntajes y las coordenadas
    dataframe[[i]] <- lapply(scores[[i]], function(score) data.frame(score, coord))
    
    # Convertir los dataframes a objetos geodata para las dos primeras componentes principales
    geodata.f1[[i]] <- lapply(dataframe[[i]], geoR::as.geodata, coords.col = 3:4, data.col = 1)
    geodata.f2[[i]] <- lapply(dataframe[[i]], geoR::as.geodata, coords.col = 3:4, data.col = 2)
    
    # Calcular los variogramas
    variog.f1[[i]] <- lapply(geodata.f1[[i]], function(g) capture.output(suppressMessages(geoR::variog(g, pairs.min = pairsmin))))
    variog.f2[[i]] <- lapply(geodata.f2[[i]], function(g) capture.output(suppressMessages(geoR::variog(g, pairs.min = pairsmin))))
  }
  
  return(list(geodata1 = geodata.f1, variogr = variog.f1))
}
