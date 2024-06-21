\name{sim_functional_process}
\alias{sim_functional_process}
\title{
Simulation of unconditional or conditional functional spatial process.
}
\description{
Given a variogram model, this functions simulates several realizations of a functional spatial process. This simulation can be conditioned to observed data.
}
\usage{
sim_functional_process(nsims,variograms,nbasis,coords,data = NULL,
                      data_coords = NULL,basis = NULL,mu = NULL,L = NULL)
}
\arguments{
  \item{nsims}{Integer giving the number of curves to simulate.}
  \item{variograms}{\code{gstat::gstatVariogram} or \code{list} of them giving the variogram model for each score. If only one is provided, it will be recycled.}
  \item{nbasis}{Integer giving the number of basis functions on which the process is going to be projected.}
  \item{coords}{Gridded \code{sp::SpatialPoints} or \code{sp::SpatialPixels}, or array coordinates of the curves that are going to be simulated.}
  \item{data}{\code{fda::fd} object containing the observed curves for conditional simulation. If data is not provided, inconditional simulation is performed.}
  \item{data_coords}{\code{sp::SpatialPoints} or array coordinates of the observed data.}
  \item{basis}{Character giving the basis of functions (only for inconditional simulation) (nbasis must be provided).}
  \item{mu}{\code{fda::fd} object of the mean function of the process, default is zero. Only used in unconditional simulation.}
  \item{L}{Limits of the symetric interval centered on zero that is the domain of the basis that is going to be created in unconditional simulation case.}
}
\details{
When \code{data} is passed, conditional simulation is performed. That means that each simulated realization of the process interpolated the observed curves in \code{data}. If \code{data} is \code{NULL}, the realizations of the process are simulated without imterpolation restrictions.
}
\value{
A list of \code{nsims} \code{SpatFD} objects each one with as much curves as points are in \code{coords}.
}
\references{
Bohorquez, M., Giraldo, R. & Mateu, J. Multivariate functional random fields: prediction and optimal sampling. Stoch Environ Res Risk Assess 31, 53–70 (2017). https://doi.org/10.1007/s00477-016-1266-y
}
\author{
Samuel Sánchez Gutiérrez \email{ssanchezgu@unal.edu.co}.
}
\seealso{\code{\link{generate_basis}}
}
\examples{
\donttest{
library(gstat)
library(fda)
library(sp)

data("CanadianWeather")
canada.CRS <- CRS("+init=epsg:4608")
coords <- SpatialPoints(CanadianWeather$coordinates,
                        proj4string = CRS("+init=epsg:4326"))
coords <- spTransform(coords,canada.CRS)
obs <- CanadianWeather$dailyAv[,,1] # Temperature

Lfd_obj <- int2Lfd(m = 2)
create.bspline.basis(rangeval = c(1,365),
                     nbasis = 40, norder = 4) -> mi.base
mi.fdPar <- fdPar(mi.base, Lfd_obj, lambda = 7.389)
mi.fd <- smooth.basis(argvals = 1:365,
                      y = obs, fdParobj = mi.fdPar)

nbasis <- 5
canada <- mi.fd$fd
canada.pca <- pca.fd(canada,nharm = 10)
base_ort <- canada.pca$harmonics[1:nbasis]
canada_mean <- canada.pca$meanfd

formula2fd <- function(rango, expresion) {
  # Generate grid
  n <- 500  # length of the grid
  x <- seq(rango[1], rango[2], length.out = n)
  
  # evaluate expression on the grid
  y_vals <- eval(parse(text = expresion))
  
  # convert to fd
  basis <- create.bspline.basis(rangeval = rango, nbasis = 30)
  fd_obj <- Data2fd(x, y_vals,basisobj = basis)
  
  return(fd_obj)
}
media <- formula2fd(c(-1,1),"3*sin(x*4)")

# No conditional
vario <- vgm(.25, "Exp", .5, .05)
nbasis <- 6
sims <- sim_functional_process(10,vario,nbasis,coords,basis = 'Legendre',mu = media)
class(sims)
length(sims)

class(sims[[1]])
# plot(sims[[3]][[1]]$data_fd)

sims <- sim_functional_process(10,vario,nbasis,coords,basis = 'Legendre')
class(sims)
length(sims)
class(sims[[1]])
# plot(sims[[3]][[1]]$data_fd)

# Conditional
vario <- vgm(100, "Exp", 900, 10)
new_coords <- spsample(coords,100,type = "regular")
gridded(new_coords) <- TRUE
length(new_coords)
a <- sim_functional_process(10,vario,nbasis,new_coords,canada,coords)
class(a)
length(a)
class(a[[1]])
#plot(a[[1]][[1]]$data_fd)

vario <- vgm(100, "Wav", 900, 10)
a <- sim_functional_process(10,vario,nbasis,new_coords,canada,coords)
class(a)
length(a)
class(a[[1]])
#plot(a[[1]][[1]]$data_fd)
}
}
