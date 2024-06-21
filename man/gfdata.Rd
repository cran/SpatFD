\name{gfdata}
\alias{gfdata}
\title{
  Creates gfdata objects.
}
\description{
  Creates an object of the class gfdata from spatial coordinates, and functions
   or time-series observed at each spatial location.  Time series is a generic term. 
   In fact, observations might be across the frequency or across another spatial
    dimension such as depth, instead of time.
}
\usage{
  gfdata(data, p, basis = "Bsplines", coords = NULL, nbasis = NULL, 
                      names = NULL, lambda = 0)
}
\arguments{
  \item{data}{Data must be provided in a matrix where each column corresponds 
  to a subject, and the rows are a sequence of data points, that is, the rows 
  are ordered according to time, frequency, depth, …. Also must include a column 
  with classes for classification 
  in the last column
  }
  \item{p}{Number of repetitions for each class}
  \item{basis}{Basis functions. "Fourier" or "Bsplines". By default, "Bsplines".
  }
  \item{coords}{A matrix with spatial coordinates (x,y). 
  }
  \item{nbasis}{The number of basis functions.
  }
  \item{names}{Names for the data classes.}
  \item{lambda}{The value of the smoothing parameter.
  }
}
\details{The gfdata-objects storage the functional data, its parameters, the functional 
          principal component analysis results, and the spatial coordinates for 
          each variable. Each variable has its own functional data, data-frame or matrix
          and its spatial coordinates file.
}
\value{
  For each subject and class: The functional data and functional principal components 
  linked with spatial coordinates.
}
\references{
  Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction 
  of functional data. Statistical Methods & Applications, 25(1), 39-54.
  
  Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: 
  prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 
  31, pages53–70 (2017).
}

  \author{Venus Puertas \email{vpuertasg@unal.edu.co}.
}


\seealso{
  \code{\link{summary.gfdata}}
}
\examples{
  \donttest{
    library(SpatFD)
    data(vowels)
    
    #### Create parameters and names for the data.
    p = 228 ; nelec = 21 ; nvow = 5
    names_vowels = c("a","e","i","o","u")
    n.basis<-c(14,13,12,13,11)
    
    s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
    
  }
}

\keyword{Functional geostatistics}
\keyword{Spatial data}
