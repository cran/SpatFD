\name{summary.SpatFD}
\alias{summary.SpatFD}
\title{Summary of SpatFD objects
}
\description{
  This functions shows a summary of the main objects of SpatFD objects.
}
\usage{
  \method{summary}{SpatFD}(object, ...)
}

\arguments{
  \item{object}{
    Object of class 'SpatFD'.
  }
  \item{...}{arguments from summary.}
}
\value{For each variable included in the SpatFd object, this functions return: Head of data, Coordinates, Eigenvalues, Mean coefficients, Proportion of explained variance by each component
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}
\author{
  Joan Nicolás Castro \email{jocastroc@unal.edu.co}.
}
\seealso{
\code{\link{SpatFD}}
  }
\examples{
# Load data
data(AirQualityBogota)

# Create an univariate object using 2 nharm
SFD_PM10 <- SpatFD(PM10, coords = coord[,2:3], basis = "Bsplines", nbasis = 91,
lambda = 0.00002, nharm = 2)
summary(SFD_PM10)
}
\keyword{Functional geostatistics}
