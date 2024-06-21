\name{mclass_data}
\alias{mclass_data}
\title{Get the mean of means for each class}
\usage{
  mclass_data(mean.mean, n.basis, type.basis = "bspline")
}
\arguments{
  \item{mean.mean}{A list of means for each class.}
  
  \item{n.basis}{A list of basis functions for each class.}
  
  \item{type.basis}{Type of basis functions to use (e.g., "bspline", "fourier").}
}
\value{
  A data frame containing the generated vowel data.
}
\description{
  This function generates multivariate vowel data based on the provided mean functions
  and basis functions.
}
\examples{
\donttest{
  data(vowels)

#### Create parameters and names for the data.
p = 228 ; nelec = 21 ; nvow = 5
names_vowels = c("a","e","i","o","u")
n.basis<-c(14,13,12,13,11)
s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
s4.sep=gfd_clasif_data(s4.gfdata, 0.8,seed = 2910)
s4.train=s4.sep$train
s4.test=s4.sep$test
mean_mean <- mean_mean(s4.train)
class_mean <- mclass_data(mean_mean,n.basis)
}
}