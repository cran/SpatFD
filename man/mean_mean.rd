\name{mean_mean}
\alias{mean_mean}
\title{Calculate Mean Functions for Each Class}
\usage{
  mean_mean(data.train.pca)
}
\arguments{
  \item{data.train.pca}{A list of PCA results from training data.}
}
\value{
  A list of mean functions for each class.
}
\description{
  This function calculates the mean functions for each class based on PCA results from training data.
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
mean_mean <- mean_mean(s4.train)
}
