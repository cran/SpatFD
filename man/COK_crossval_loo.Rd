\name{COK_crossval_loo}
\alias{COK_crossval_loo}
\title{
Leave-One-Out Cross-Validation for Functional cokriging
}
\description{
This function performs leave-one-out cross-validation for functional cokriging. It systematically leaves out one 
location at a time from the dataset, fits the model to the remaining data, and then makes a prediction for the left-out observation. 
It is used to assess the predictive performance of the functional cokriging model.
}
\usage{
COK_crossval_loo(object, plot_show, var, show_all)
} 
\arguments{
  \item{object}{A 'COKS_pred' object obtained with function \code{COKS_scores_lambdas}.}
    \item{plot_show}{A logical value. If \code{TRUE}, the function will generate and display a plot of the cross-validation results. If \code{FALSE}, no plot will be displayed. Default is \code{True}.}
    \item{var}{A numerical value indicating the number of the variable to be used in the cross-validation. Default is \code{1}.}
    \item{show_all}{A logical value. If \code{TRUE}, the function will display all graphs at once, else it will display them one by one. Default is \code{FALSE}.}

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
Venus Puertas \email{vpuertasg@unal.edu.co}
}
\seealso{\code{\link{recons_fd}}, \code{\link{KS_scores_lambdas}}}
\examples{
# Load the data and the required packages
library(SpatFD)
library(gstat)
data(COKMexico)

# Create the SpatFD data objects
SFD_PM10_NO2 <- SpatFD(Mex_PM10, coords = coord_PM10, basis = "Fourier", 
                       nbasis = 21, lambda = 0.000001, nharm = 2,
                       name = names(Mex_PM10))
SFD_PM10_NO2 <- SpatFD(NO2, coords = coord_NO2, basis = "Fourier", 
                       nbasis = 27, lambda = 0.000001, nharm = 2,
                       add = SFD_PM10_NO2,name = names(NO2))

# Fit the model
model1 <- gstat::vgm(647677.1,"Gau",23317.05)
model1 <- gstat::vgm(127633,"Wav",9408.63, add.to = model1)

# Perform the cokriging
newcoords <- data.frame(x = 509926,y = 2179149)
coks <- COKS_scores_lambdas(SFD_PM10_NO2,newcoords,model1)
\donttest{
# Perform the cross-validation along NO2
COK_crossval_loo(object = coks, var = 2,show_all=TRUE)
}
}
\keyword{Cross-validation}
\keyword{Leave-one-out}
\keyword{Spatial prediction}
\keyword{Functional kriging}
