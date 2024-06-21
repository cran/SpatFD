\name{gfd_variog_geoR}
\alias{gfd_variog_geoR}
\title{Generate Variograms for Functional Data from a gfdata object}
\usage{
  gfd_variog_geoR(gfd_pca_Data, pairsmin = 2)
}
\arguments{
  \item{gfd_pca_Data}{A list of PCA results for functional data.}
  
  \item{pairsmin}{Minimum number of pairs for variogram calculation.}
}
\value{
  A list containing geodata objects and variograms.
}
\description{
  This function generates variograms for functional data based on PCA results.
}
\examples{
  data(vowels)
  
  #### Create parameters and names for the data.
  p = 228 ; nelec = 21 ; nvow = 5
  names_vowels = c("a","e","i","o","u")
  n.basis<-c(14,13,12,13,11)
  s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
  
  s4.sep=gfd_clasif_data(s4.gfdata, 0.8,seed = 2910)
  
  s4.train=s4.sep$train
  
  s4.var.geoR=gfd_variog_geoR(s4.train)
}
