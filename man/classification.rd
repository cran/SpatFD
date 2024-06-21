\name{classification}
\alias{classification}
\title{Classification Function for Functional Data}
\usage{
  classification(data.train.pca, new.basis, k, distance, mcov = NULL)
}
\arguments{
  \item{data.train.pca}{A list of PCA results from training data.}
  
  \item{new.basis}{Basis object from the test data}
  
  \item{k}{Number of nearest neighbors to consider for classification.}
  
  \item{distance}{Type of distance to use (e.g., "euclidean", "mahalanobis").}
  
  \item{mcov}{Optional covariance matrices for Mahalanobis distance.}
}
\value{
  The predicted class for the new data.
}
\description{
  This function classifies new functional data based on PCA results from training data.
}
\examples{
  
  data(vowels)
  #### Create parameters and names for the data.
  p = 228 ; nelec = 21 ; nvow = 5
  names_vowels = c("a","e","i","o","u")
  n.basis<-c(14,13,12,13,11)
  s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
  # Create train and test data
  s4.sep=gfd_clasif_data(s4.gfdata, 0.8,seed = 2910)
  s4.train=s4.sep$train
  s4.test=s4.sep$test
  
  # Classification
  cla<-classification(data.train.pca = s4.train,
                     new.basis=s4.test[[1]]$data_fd[[1]],
                     k=4,
                     distance='euclidean',
                     mcov = mcov
  )
  
}
