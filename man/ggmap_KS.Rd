\name{ggmap_KS}
\alias{ggmap_KS}
\title{
Map plot of a 'KS_pred' object
}
\description{
A visualization of the predicted kriging in a colormap for a specific window time.
}
\usage{
ggmap_KS(KS, map_path, window_time = NULL, method = "lambda", map_n = 5000,
zmin = NULL, zmax = NULL, graph = "plotly")
}
\arguments{
  \item{KS}{
Object of class 'KS_pred'. Not NULL.
}
  \item{map_path}{
Character indicating the directory of the shape file or an object of class SpatialPolygonDataFrame load from a shape file by \code{rgdal::readOGR}. If NULL the prediction is plot in a rectangle. Default NULL.

}
  \item{window_time}{
numeric. Vector of window time to see the spatial prediction. If NULL choose the range values of KS$SFD. Default NULL.
}
  \item{method}{
character. "lambda" or "scores". Default "lambda".
}
  \item{map_n}{
numeric. Number of points to sample in the map. Default 5000.
}
  \item{zmin}{
numeric. Minimum value predicted for the color scale. If NULL is chosen from the data. Default NULL.
}
  \item{zmax}{
numeric. Maximum value predicted for the color scale. If NULL is chosen from the data. Default NULL.
}
 \item{graph}{
character. "plotly" or "gg" whether to use plotly or ggplot graphics. Default "plotly".
}
}
\value{
Plotly or ggplot image
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}
\author{
Diego Sandoval \email{diasandovalsk@unal.edu.co}.
}
\seealso{
\code{\link{KS_scores_lambdas}}
}
\examples{
library(gstat)
data(AirQualityBogota)
newcoorden=data.frame(X=seq(93000,105000,len=100),Y=seq(97000,112000,len=100))

SFD_PM10 <- SpatFD(PM10, coords = coord[, -1], basis = "Bsplines", nbasis = 17,
norder=5, lambda = 0.00002, nharm=3)

modelos <- list(vgm(psill = 2634000, "Exp", range = 2103.25, nugget =  0),
                vgm(psill = 101494.96, "Exp", range = 1484.57, nugget = 0),
                vgm(psill =53673, "Exp", range = 42406, nugget =  0))

KS_SFD_PM10_both <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "both",
model = modelos)
\donttest{
ggmap_KS(KS_SFD_PM10_both,
         map_path = map,
         window_time = c(5108,5109,5110),
         method = "scores",
         zmin = 50,
         zmax = 120)
         }
}
\keyword{colormap}
