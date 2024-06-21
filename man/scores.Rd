\name{scores}
\alias{scores}
\title{
Spatial random field of scores
}
\description{
Creates a list of P data-frames, one for each of the P spatial functional variables in the SpatFD-object.  Each data-frame contains one column for each harmonic selected with its respective n_p-score values, and two additional columns for horizontal and vertical spatial coordinates.
}
\usage{
scores(X)
}
\arguments{
  \item{X}{An object of class SpatFD.
}
}
\details{
For a SpatFD object with P spatial functional variables measured on n_p locations each, and nharm=k_p, p=1,..., P. The scores-function builds a data-frame with n_p rows and k_p+2 columns. The first two columns are the horizontal and vertical spatial coordinates x,y.  The rest of the columns are the score values for each of the first k_p harmonics selected for the p variable, at each of the n_p locations.
}
\value{A list with P data-frames, with dimension \eqn{n_p \times k_p+2}, each. p=1,…,P.
}
\references{
Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Optimal sampling for spatial prediction of functional data. Statistical Methods & Applications, 25(1), 39-54.

Bohorquez, M., Giraldo, R., & Mateu, J. (2016). Multivariate functional random fields: prediction and optimal sampling. Stochastic Environmental Research and Risk Assessment, 31, pages53–70 (2017).
}

\author{Diego Sandoval \email{diasandovalsk@unal.edu.co}.
}
\note{
Functional principal components (FPCA) are applied to the centered data. The scores are scalar second order stationary Random fields, in virtue of the requirements for FPCA. Hence, the covariance function exists, that is, models are bounded, and always have sill and range parameters. Of course,  some models have additional parameters, such as smoothing parameters. From the theoretical perspective, in this case, there is no possibility of non-bounded variogram models. The spatial covariance between two curves is determined by the sum of the covariance between spatial score vectors associated,  see Bohorquez, Giraldo and Mateu 2016 and Bohorquez, Giraldo and Mateu 2021. This covariance can be modeled using the usual packages for geostatistical analysis, such as geoR and gstat.  Finally, the sill of the variogram model for each dimension is bounded for the respective eigenvalue. Actually, an adequate option is to use this eigenvalue as sill and estimate the rest of the parameters.
}

\seealso{
\code{\link{SpatFD}}
}
\examples{
data(AirQualityBogota)
newcoorden=data.frame(X=seq(93000,105000,len=100),Y=seq(97000,112000,len=100))
# Building the SpatFD object
SFD_PM10 <- SpatFD(PM10, coords = coord[, -1], basis = "Bsplines", nbasis = 17,
norder=5, lambda = 0.00002, nharm=3)
scores(SFD_PM10)
}

\keyword{Functional principal component analysis}
\keyword{Spatial process}
\keyword{Scores}
