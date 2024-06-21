\name{ggplot_KS}
\alias{ggplot_KS}
\title{
ggplot of predicted functions
}
\description{
Plot with or without predicted variance in each spatial location of the functional kriging.
}
\usage{
ggplot_KS(KS, show.varpred = FALSE, main = "Functional Data",
main2 = "Functional Data", ylab = "Value", xlab = "Time", ndigits = 2,
palette.plot = c("#440154FF", "#3336FF", "#33FCFF", "#33FF4C", "#FDE725FF"))
}
\arguments{
  \item{KS}{
Object of class 'KS_pred'. Not NULL.
}
  \item{show.varpred}{
Boolean. If the predicted variance is shown. Default FALSE.
}
  \item{main}{
character. Title of the plot.Default "Functional Data".
}
  \item{main2}{
character. If there are two methods where used, the title of the second plot. Default "Functional Data".
}
  \item{ylab}{
character. Name of the y-axis.
}
  \item{xlab}{
character. Name of the x-axis.
}
  \item{ndigits}{
numeric. Number of decimals for the predicted variance if shown. Default 2.
}
\item{palette.plot}{
list. String values of hexadecimal colors. Default c("#440154FF", "#3336FF", "#33FCFF", "#33FF4C", "#FDE725FF")  
}
}
\value{
ggplot. If there are two plots a list of ggplots.
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
newcoorden=data.frame(X=seq(93000,105000,len=10),Y=seq(97000,112000,len=10))
SFD_PM10 <- SpatFD(PM10, coords = coord[, -1], basis = "Bsplines", nbasis = 17,
norder=5, lambda = 0.00002, nharm=3)
modelos <- list(vgm(psill = 2634000, "Exp", range = 2103.25, nugget =  0),
                vgm(psill = 101494.96, "Exp", range = 1484.57, nugget = 0),
                vgm(psill =53673, "Exp", range = 42406, nugget =  0))

KS_SFD_PM10_both <- KS_scores_lambdas(SFD_PM10, newcoorden, method = "both",
model = modelos)
\donttest{
ggplot_KS(KS_SFD_PM10_both,show.varpred = FALSE,
          main = "Plot 1 - Using Scores",
          main2 = "Plot 2 - Using Lambda",
          ylab = "PM10")
          }
}
\keyword{Functional data}
