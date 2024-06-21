\name{CrossSpatFD}
\alias{CrossSpatFD}
\title{
Creates univariate and multivariate CrossSpatFD object to perform crossed validation for functional spatial prediction.
}
\description{
  Creates univariate and multivariate CrossSpatFD object considering the base od a SpatFD or FD object to perform crossed validation for functional spatial prediction.
}
\usage{
CrossSpatFD(data,coords,basis,lambda=0,nharm=NULL,name=NULL,add=NULL,...)
}
\arguments{
  \item{data}{Data must be provided in a data-frame or a matrix where each column corresponds to a location, and the rows are a sequence of data points, that is, the rows are ordered according to time, frequency, depth, …. Data can also be an fd-object from the fda package.
}
  \item{coords}{A data-frame or a matrix with spatial coordinates (x,y). The number of columns in data must coincide with the number of rows in coords for each variable.
}
  \item{basis}{The basis from the SpatFD or FD object.
}
  \item{lambda}{The value of the smoothing parameter.
}
  \item{nharm}{The number of harmonics or eigenfunctions to be reported in the Functional Principal Components results if vp is not given.
}
%  \item{vp}{Threshold for the cumulative proportion of explained variance to select the number of components if nharm is not given.}
\item{name}{A new name for data can be assigned.}
  \item{add}{
Other variables can be added for spatial multivariate functional prediction, that is, for functional cokriging. It is not necessary that all variables are observed at the same spatial locations.
}
  \item{\dots}{
arguments from fda create.bspline.basis or create.fourier.basis.
}
}
\details{The CrossSpatFD-objects storage the functional data, its parameters, the functional principal component analysis results, and the spatial coordinates for each variable. Each variable has its own functional data, data-frame or matrix and its spatial coordinates file.
}
\value{
For each variable: The functional data and functional principal components linked with spatial coordinates.
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.

Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}

\author{Diego Sandoval \email{diasandovalsk@unal.edu.co} & Angie Villamil \email{acvillamils@unal.edu.co}.
}

\note{
1. 
This function is for internal use and should not be implemented directly
}

\seealso{
\code{\link{summary.SpatFD}}
}

\keyword{Functional geostatistics}
\keyword{Spatial data}
