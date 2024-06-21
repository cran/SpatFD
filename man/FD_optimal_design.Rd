\name{FD_optimal_design}
\alias{FD_optimal_design}
\title{
Optimal Spatial Design For Functional Data
}
\description{
Given a variogram model and a set of points in which we want to predict certain variable optimally, this function finds where must be placed the stations in which the information will be collected for functional or scalar data.
}
\usage{
FD_optimal_design(k, s0, model, fixed_stations = NULL,
                   scalar = FALSE, nharm = NULL,
                   method = "lambda", grid = NULL,
                   map = NULL, plt = FALSE)
}
\arguments{
  \item{k}{The number of new stations that are going to be located.}
  \item{s0}{\code{matrix}, \code{array}, \code{data.frame}, or \code{SpatialPoints} object that contains the coordinates of the points in which we want to optimally predict using functional kriging. Each row corresponds to each point.
  If you want to predict optimally in a certain area, you must create a random sample large enough of points of that area and pass it to this function.}
  \item{model}{A \code{VariogramModel} from \code{gstat} package or a list of \code{VariogramModels} objects if a distinct model is going to be used for each harmonic. For scalar data only one model is needed.}
  \item{fixed_stations}{If there are already some stations on the field that are not going to be removed, here should be passed their coordinates. The object must be of class \code{matrix}, \code{array}, \code{data.frame}, \code{SpatialPoints}, \code{SpatFD}, or \code{NULL} if there are no fixed stations.}
  \item{scalar}{Boolean that indicates if the optimization is for functional data (FALSE) or scalar data (TRUE). If TRUE, nharm is set to 1.}
  \item{nharm}{Number of harmonics of the functional principal components that will be used in the prediction. If it is not specified it will be set to the number of models passed, then this parameter shouldn't be specified for scalar data.}
  \item{method}{Functional kriging method that will be used. Currently available "lambda" and "scores". See details bellow.}
  \item{grid}{Coordinates in which the new stations can be located. \code{grid} must be of type \code{matrix}, \code{array}, \code{data.frame}, \code{SpatialPoints}. If you don't pass \code{grid}, you must pass \code{map}; if you pass both, \code{map} will be used.}
  \item{map}{Spatial object from sp package such as \code{Line}, \code{Lines}, \code{Polygon}, \code{SpatialPolygons}, \code{SpatialGrid} or \code{SpatialPixels} in which the new stations will be located. This object will also be used for creating the plot.}
  \item{plt}{\code{TRUE} or \code{FALSE}. If \code{TRUE}, a nice \code{ggplot2} plot with the result will be generated. Se example bellow.}
}
\details{
Bohorquez, M., Giraldo, R., Mateu, J. (2016) present several methods for finding the best combination predictor-design according to the kriging prediction error variance for functional data. They show different functional kriging methods and two of them are implemented on this function.

If method is "lambda", optimal spatial sampling using FPCA and simple kriging will be used (see section 3.2 of Bohorquez, M., Giraldo, R., Mateu, J. (2016)). If method is "scores", simple kriging will be applied on each harmonic and the total variance will be minimized. This total variance is computed as follows:

\deqn{TotVar = \sum_{j=1}^{nharm}V_j}

where \eqn{V_j} is the variance of the simple kriging prediction of j-th score.
}
\value{
The function returns an \code{OptimalSpatialDesign} object that is a list with the following elements:

  \item{new_stations}{\code{matrix} \code{array} object with the coordinates of the new stations.}
  \item{fixed_stations}{\code{matrix} \code{array} object with the coordinates of the fixed stations.}
  \item{plot}{\code{ggplot2} plot.}

}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.
}
\author{
Nathaly Vergel Serrano \email{nvergel@unal.edu.co} & Samuel Sánchez Gutiérrez \email{ssanchezgu@unal.edu.co}.
}
\note{
'lambda' method tends to be faster than 'scores' method.
}

\section{Warning}{
When method is 'lambda', the minimized value is not the variance, but the negative of expression (12) in Bohorquez, M., Giraldo, R., & Mateu, J. (2016), that is

\deqn{-\sum_{l = 1}^L \varsigma_l'\Omega^{-1}\varsigma_l}
}

\seealso{\code{\link{print.OptimalSpatialDesign}}
}
\examples{
\donttest{
library(gstat)
s0 <- cbind(2*runif(100),runif(100)) # random coordinates on (0,2)x(0,1)
fixed_stations <- cbind(2*runif(4),runif(4))
x_grid <- seq(0,2,length = 30)
y_grid <- seq(0,1,length = 30)
grid <- cbind(rep(x_grid,each = 30),rep(y_grid,30))
model  <- vgm(psill = 5.665312,
                  model = "Exc",
                  range = 8000,
                  kappa = 1.62,
                  add.to = vgm(psill = 0.893,
                               model = "Nug",
                               range = 0,
                               kappa = 0))
FD_optimal_design(k = 10, s0 = s0, model = model,
                  grid = grid, nharm = 2, plt = TRUE,
                  fixed_stations = fixed_stations) -> OSD
OSD$new_stations
OSD$fixed_stations
OSD$plot
class(OSD)
}
}
