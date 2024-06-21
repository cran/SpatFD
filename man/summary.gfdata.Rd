\name{summary.gfdata}
\alias{summary.gfdata}
\title{Summary of gfdata objects
}
\description{
  This functions shows a summary of the main objects of gfdata objects.
}
\usage{
  \method{summary}{gfdata}(object, ...)
}

\arguments{
  \item{object}{
    Object of class 'gfdata'.
  }
  \item{...}{arguments from summary.}
}
\value{For each variable included in the gfdata object, this functions return: Head of data, Coordinates, Eigenvalues, Mean coefficients, Proportion of explained variance by each component
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}
\author{
  Joan Nicolás Castro \email{jocastroc@unal.edu.co}, Venus Celeste Puertas \email{vpuertasg@unal.edu.co}
}
\seealso{
\code{\link{gfdata}}
  }
\examples{
data(vowels)

#### Create parameters and names for the data.
p = 228 ; nelec = 21 ; nvow = 5
names_vowels = c("a","e","i","o","u")
n.basis<-c(14,13,12,13,11)
s4.gfdata = gfdata(data=vowels,p=p,names=names_vowels,coords=vowels_coords,nbasis=n.basis)
summary.gfdata(object=s4.gfdata)
}
\keyword{Functional geostatistics}
