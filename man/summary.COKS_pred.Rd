\name{summary.COKS_pred}
\alias{summary.COKS_pred}
\title{Summary of COKS_pred objects
}
\description{
  This functions shows a summary of the main objects of COKS_pred objects.
}
\usage{
  \method{summary}{COKS_pred}(object, ...)
}
\arguments{
  \item{object}{
    Object of class 'COKS_pred'.
  }
  \item{...}{arguments from summary}
}
\value{This functions prints according to method computed: eigenvalues, variance of prediction and each of the models.
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).

}
\author{
  Joan Nicolás Castro \email{jocastroc@unal.edu.co}.
}
\seealso{
\code{\link{COKS_scores_lambdas}}
}
\examples{
data(COKMexico)
SFD_PM10_NO2 <- SpatFD(Mex_PM10, coords = coord_PM10, 
basis = "Fourier", nbasis = 21, lambda = 0.000001, nharm = 2)
SFD_PM10_NO2 <- SpatFD(NO2, coords = coord_NO2, 
basis = "Fourier", nbasis = 27, lambda = 0.000001, 
nharm = 2,add = SFD_PM10_NO2)
model1 <- gstat::vgm(647677.1,"Gau",23317.05)
model1 <- gstat::vgm(127633,"Wav",9408.63, add.to = model1)
newcoords <- data.frame(x = 509926,y = 2179149)
coks <- COKS_scores_lambdas(SFD_PM10_NO2,newcoords,model1)
summary(coks)

}
\keyword{Prediction}

