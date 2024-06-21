scores <- function(X){
        if (inherits(X,"SpatFD") ) {
          puntaje=list()
          puntajes=list()
          name_puntajes = c()
          for(j in 1:length(X)){
               puntaje[[j]]=X[[j]]$fpca$scores
               rownames(puntaje[[j]])=X[[j]]$coordsnames
               
               # Cambiar los nombres de las columnas de scores
               new_colnames = paste0("sc", 1:ncol(puntaje[[j]]), "_", X[[j]]$variable_name)
               colnames(puntaje[[j]]) = new_colnames
               
               puntajes[[j]]= data.frame(X[[j]]$coords, puntaje[[j]])
               name_puntajes[j] = X[[j]]$variable_name
        }
        names(puntajes) = name_puntajes
        } else if(inherits(X,"scores_pred")){
          puntajes = X$scores_pred
        } else {
          stop("Wrong class of X object. It must be of class SpatFD or scores_pred")
        }
        return(puntajes)
}
