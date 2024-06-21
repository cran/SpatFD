\name{create_mcov}
\alias{create_mcov}
\title{Create Covariance Matrices given a series of spatial model parameters}
\usage{
  create_mcov(coordenadas, t.models)
}
\arguments{
  \item{coordenadas}{A matrix of coordinates.}
  
  \item{t.models}{A data frame with model parameters.}
}
\value{
  A list of covariance matrices.
}
\description{
  This function creates covariance matrices for spatial data based on the provided model parameters.
}
\examples{
  
  data(vowels)
  t.models = data.frame(sill = c(1887.47,1447.27,3533.96,1850.27,432.63),
                      phi  = c(106.68,109.1,19.4,150.32,31.52),
                      tausq =c(0,0,0,0,0),
                      model = as.character(c("gaussian","gneiting",
                                             "matern","cubic",
                                             "wave")),
                      kappa = c(0,0,7.3,0,0)
                      
)
create_mcov(vowels_coords,t.models)
  
}
