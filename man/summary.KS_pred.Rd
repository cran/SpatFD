\name{summary.KS_pred}
\alias{summary.KS_pred}
\title{Summary of KS_pred objects
}
\description{
  This functions shows a summary of the main objects of KS_pred objects.
}
\usage{
  \method{summary}{KS_pred}(object, ...)
}
\arguments{
  \item{object}{
    Object of class 'KS_pred'.
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
\code{\link{KS_scores_lambdas}}
}
\examples{
library(gstat)
data(AirQualityBogota)

newcoorden=data.frame(X=110000,Y=125000)

# Recibir los datos, suavizarlos y ACP
SFD_PM10 <- SpatFD(PM10, coords = coord[,2:3], basis = "Bsplines", nbasis = 17,
norder=5, lambda = 0.00002, nharm=3)

#Variogram model for each component
modelos <- list(vgm(psill = 2634000, "Exp", range = 2103.25, nugget =  0),
                vgm(psill = 101494.96, "Exp", range = 1484.57, nugget = 0),
                vgm(psill =53673, "Exp", range = 42406, nugget =  0))

#Genera los scores y los lambdas para predecir en nuevas coordenadas

#method = "lambda"
KS_SFD_PM10_l <- KS_scores_lambdas(SFD_PM10, newcoorden ,method = "lambda",
model = modelos)
summary(KS_SFD_PM10_l)

}
\keyword{Prediction}

