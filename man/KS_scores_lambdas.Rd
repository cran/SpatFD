\name{KS_scores_lambdas}
\alias{KS_scores_lambdas}
\title{
Functional Kriging
}
\description{
Linear Spatial functional prediction. Two predictors are possible: scores or lambda.
}
\usage{
KS_scores_lambdas(SFD, newcoords, model, method = "lambda", name = NULL, fill.all = NULL)
}
\arguments{
  \item{SFD}{object of class 'SpatFD'.
}
  \item{newcoords}{
The N × 2 matrix or data.frame with the spatial coordinates corresponding to the N prediction locations.
}
  \item{model}{
The scores variogram model. A variogramModel object. See gstat package.
}
  \item{method}{
Prediction method: "lambda" or "scores". By default "lambda". See details.
}
  \item{name}{
The variable to predict in SpatFD object. By default, the predictions is performed for the first variable in the SpatFD object.
}
  \item{fill.all}{
gstat function parameter. If there are more than 1 score vector and not all models or a valid and complete linear model of coregionalization is given, fill all of the direct and cross variogram model with the only model given.
}
}
\details{
 "lambda" option corresponds to the predictor \eqn{\breve{\chi}_{\bm s_0}(t)}, given by
\deqn{\breve{\chi}_{\bm s_0}(t)=\sum\limits_{i=1}^{n}\lambda_i\chi_{\bm s_i}(t)}
and weigths are found such that minimize
\eqn{\left\|\bm\chi_{\bm s_0}(t)-\breve{\chi}_{\bm s_0}(t)\right\|^2}.

"scores" method performs kriging or cokriging directly on the scores and predictions are used to build the functional prediction

It is used simple cokriging to predict the vector \eqn{\bm f(\bm s_0)=\left(f_1(\bm s_0),...,f_K(\bm s_0)\right)^T} at the unsampled location \eqn{\bm s_0}. The predictor is \eqn{f^*(\bm s_0)}, so the prediction of the curve \eqn{\chi_{\bm s_0}(t)} is \eqn{\chi^*_{\bm s_0}(t)=\bm \xi^T(t)\bm f^*(\bm s_0),\;\;\;\;\;\;i=1,...,n}.
}
\value{
Returns a 'KS_pred' object with functional kriging:
weights (lambda) using the first method and kriging score predictions using the second method in Bohorquez, M., Giraldo, R., & Mateu, J. (2016).
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.

Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).

Bohorquez M.; Giraldo R. and Mateu J. Spatial prediction and optimal sampling of functional data in Geostatistical Functional Data Analysis: Theory and Methods (2021).  John Wiley  Sons, Chichester, UK. ISBN: 978-1-119-38784-8. https://www.wiley.com/en-us/Geostatistical+Functional+Data+Analysis-p-9781119387848.
}
\author{
Diego Sandoval \email{diasandovalsk@unal.edu.co} & Angie Villamil \email{acvillamils@unal.edu.co}.
}
\seealso{
\code{\link{SpatFD}},\code{\link{summary.KS_pred}}
}
\examples{
library(gstat)
data(AirQualityBogota)

newcoorden=data.frame(X=110000,Y=125000)

# Recibir los datos, suavizarlos y ACP
SFD_PM10 <- SpatFD(PM10, coords = coord[,2:3], basis = "Bsplines",
nbasis = 17,norder=5, lambda = 0.00002, nharm=3)

#Variogram model for each component
modelos <- list(vgm(psill = 2634000, "Exp", range = 2103.25, nugget =  0),
                vgm(psill = 101494.96, "Exp", range = 1484.57, nugget = 0),
                vgm(psill =53673, "Exp", range = 42406, nugget =  0))

#Genera los scores y los lambdas para predecir en nuevas coordenadas

#method = "lambda"
KS_SFD_PM10_l <- KS_scores_lambdas(SFD_PM10, newcoorden ,method = "lambda",
model = modelos)
class(KS_SFD_PM10_l)

#method = "scores"
KS_SFD_PM10_sc <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "scores",
model = modelos)

#method = "both"
KS_SFD_PM10_both <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "both",
model = modelos)
}
\keyword{Spatial functional prediction}
\keyword{Functional kriging}
\keyword{Spatial correlation}
\keyword{Spatio-temporal data}
\keyword{Functional random field}
