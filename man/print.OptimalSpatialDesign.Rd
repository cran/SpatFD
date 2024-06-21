\name{print.OptimalSpatialDesign}
\alias{print.OptimalSpatialDesign}
\title{Print of OptimalSpatialDesign objects
}
\description{
This functions prints a summary of the main objects of OptimalSpatialDesign objects.
}
\usage{
\method{print}{OptimalSpatialDesign}(x, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
Object of class 'OptimalSpatialDesign'.
}
\item{...}{arguments from print}
}
\value{Shows the amount of fixed stations, new stations and the first six new coordinates.
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.
}
\author{
Samuel Sánchez Gutiérrez \email{ssanchezgu@unal.edu.co}.
}
\seealso{
\code{\link{FD_optimal_design}}
}
\examples{
library(gstat)
data(AirQualityBogota)

vgm_model  <- gstat::vgm(psill = 5.665312,
                  model = "Exc",
                  range = 8000,
                  kappa = 1.62,
                  add.to = vgm(psill = 0.893,
                               model = "Nug",
                               range = 0,
                               kappa = 0))

my.CRS <- sp::CRS("EPSG:21899") # https://epsg.io/21899
map <- as(map, "Spatial")

bogota_shp <- sp::spTransform(map,my.CRS)
target <- sp::spsample(bogota_shp,n = 100, type = "random")
# The set of points in which we want to predict optimally.
old_stations <- sp::spsample(bogota_shp,n = 3, type = "random")
# The set of stations that are already fixed.
\donttest{
FD_optimal_design(k = 10, s0 = target,model = vgm_model,
               map = map,plt = TRUE,#method = "scores",
               fixed_stations = old_stations) -> res
print(res)
}
}
\keyword{Optimal Spatial Design}
