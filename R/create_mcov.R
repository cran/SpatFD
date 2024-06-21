create_mcov <- function(coordenadas, t.models) {
  mcov <- list()
  for (i in 1:nrow(t.models)) {
    model_name <- t.models$model[i]
    cov_pars <- t.models[i, 1:2]
    nug <- t.models$tausq[i]
    kappa <- t.models$kappa[i]
    
    cov_matrix <- geoR::varcov.spatial(coordenadas, cov.model = model_name, cov.pars = cov_pars, nug = nug, kappa = kappa)[[1]]
    mcov[[i]] <- cov_matrix
  }
  return(mcov)
}