\name{crossval_loo}
\alias{crossval_loo}
\title{
Leave-One-Out Cross-Validation for Functional Kriging
}
\description{
This function performs leave-one-out cross-validation for functional kriging and cokriging. It systematically leaves out one observation at a time from the dataset, fits the model to the remaining data, and then makes a prediction for the left-out observation. It is used to assess the predictive performance of the functional kriging model.
}
\usage{
crossval_loo(object, plot_show)
}
\arguments{
  \item{object}{A 'KS_pred' object obtained with function \code{KS_scores_lambdas}.}
    \item{plot_show}{A logical value. If \code{TRUE}, the function will generate and display a plot of the cross-validation results. If \code{FALSE}, no plot will be displayed. Default is \code{True}.}

}
\value{
An object containing the results of the leave-one-out cross-validation. Includes:
\item{performance_metrics}{Summary statistics describing the overall predictive performance, such as mean squared error.}
\item{plots}{The generation of plots showing the cross-validation results, controlled by the \code{plot_show} parameter. If \code{plot_show} is \code{TRUE}, this will contain the plots; otherwise, it will be empty.}
}

\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.

Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}

\author{
Joan Castro \email{jocastroc@unal.edu.co}.
}
\seealso{\code{\link{recons_fd}}, \code{\link{KS_scores_lambdas}}}
\examples{
# Example code demonstrating how to use the crossval_loo function
library(SpatFD)
library(gstat)

# Load data and coordinates
data(AirQualityBogota)

#s_0 nonsampled location. It could be data.frame or matrix and one or more locations of interest
newcoorden=data.frame(X=seq(93000,105000,len=100),Y=seq(97000,112000,len=100))
#newcoorden=data.frame(X=110000,Y=126000)
#newcoorden=matrix(c(110000.23,109000,109500,130000.81,129000,131000),nrow=3,ncol=2,byrow=TRUE)

# Building the SpatFD object
SFD_PM10 <- SpatFD(PM10, coords = coord[, -1], basis = "Bsplines", 
nbasis = 17,norder=5, lambda = 0.00002, nharm=3)

# Semivariogram models for each spatial random field of scores
modelos <- list(vgm(psill = 2199288.58, "Wav", range = 1484.57, nugget =  0),
                vgm(psill = 62640.74, "Mat", range = 1979.43, nugget = 0,kappa=0.68),
                vgm(psill =37098.25, "Exp", range = 6433.16, nugget =  0))

# Functional kriging. Functional spatial prediction at each location of interest
#method = "lambda"
#Computation of lambda_i
KS_SFD_PM10_l <- KS_scores_lambdas(SFD_PM10, newcoorden ,method = "lambda", 
model = modelos)
# method = "scores"
#Simple kriging of scores
KS_SFD_PM10_sc <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "scores", model = modelos)
# method = "both"
KS_SFD_PM10_both <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "both", model = modelos)

# Cross Validation 
crossval_loo(KS_SFD_PM10_l)
crossval_loo(KS_SFD_PM10_sc)
crossval_loo(KS_SFD_PM10_both)
}

\keyword{Cross-validation}
\keyword{Leave-one-out}
\keyword{Spatial prediction}
\keyword{Functional kriging}
