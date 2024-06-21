\name{recons_fd}
\alias{recons_fd}
\title{
Linear combinations for functional kriging
}
\description{
This is an internal function for functional kriging and cokriging. To perform the linear combinations to obtain functional kriging and cokriging.
Once optimization process is finished and scores or lambda are obtained, this function builds the prediction, performing the linear combination between coefficients and basis functions.
}
\usage{
recons_fd(X,name = NULL)
}
\arguments{
  \item{X}{A 'KS_pred' or 'COKS_pred' object obtained with function \code{KS_scores_lambdas} or 
  \code{COKS_scores_lambdas}}
  \item{name}{Name of the variable of interest. Default 1, the first variable.}
}
\value{
Spatial functional predictions. The fd object based on the two functional kriging methods described in Bohorquez, M., Giraldo, R., & Mateu, J. (2016).
List of
\item{fd_scores}{}
\item{fd_lambda}{}
}
\references{
%% ~
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.

Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).

Bohorquez M.; Giraldo R. and Mateu J. Spatial prediction and optimal sampling of functional data in Geostatistical Functional Data Analysis: Theory and Methods (2021).  John Wiley  Sons, Chichester, UK. ISBN: 978-1-119-38784-8. https://www.wiley.com/en-us/Geostatistical+Functional+Data+Analysis-p-9781119387848. ~
}
\author{
Diego Sandoval \email{diasandovalsk@unal.edu.co}.
}

\seealso{\code{\link{KS_scores_lambdas}}}
\examples{
library(gstat)
data(AirQualityBogota)
newcoorden=data.frame(X=110000,Y=125000)
SFD_PM10 <- SpatFD(PM10, coords = coord[,2:3], basis = "Bsplines", nbasis = 17,
norder=5, lambda = 0.00002, nharm=3)
modelos <- list(vgm(psill = 2634000, "Exp", range = 2103.25, nugget =  0),
                vgm(psill = 101494.96, "Exp", range = 1484.57, nugget = 0),
                vgm(psill =53673, "Exp", range = 42406, nugget =  0))

#method = "lambda"
KS_SFD_PM10_l <- KS_scores_lambdas(SFD_PM10, newcoorden ,method = "lambda",
model = modelos)
curves_PM10_l <- recons_fd(KS_SFD_PM10_l)
plot(curves_PM10_l)

#method = "scores"
KS_SFD_PM10_sc <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "scores",
model = modelos)
curves_PM10_sc <- recons_fd(KS_SFD_PM10_sc)
plot(curves_PM10_sc)
}

\keyword{Spatial prediction}
\keyword{Eigenfunctions}
