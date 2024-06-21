\name{gfd_clasif_data}
\alias{gfd_clasif_data}
\title{
  Divide the data in train and test dataset
}
\description{
 This function divides the data in train and test datasets
}
\usage{
  gfd_clasif_data(gfd_data, prop.train, seed = NULL) 
}
\arguments{
  \item{gfd_data}{
    Object of class 'gfdata'. Not NULL.
  }
  \item{prop.train}{
    Number between 0 and 1, indicating the proportion to be left on train dataset
  }
  \item{seed}{
    seed for the sampling algorithms
  }
}
\value{
  gfdata divided object
}
\references{
  Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}
\author{
  Diego Sandoval \email{diasandovalsk@unal.edu.co}.
}

\examples{
  library(SpatFD)
  data(vowels)
  
  #### Create parameters and names for the data.
  p = 228 ; nelec = 21 ; nvow = 5
  names_vowels = c("a","e","i","o","u")
  n.basis<-c(14,13,12,13,11)
  
  s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
  s4.sep=gfd_clasif_data(s4.gfdata, 0.8,seed = 2910)
  
  s4.train=s4.sep$train
  s4.test=s4.sep$test
  
}
\keyword{split}
\keyword{train}
\keyword{test}
