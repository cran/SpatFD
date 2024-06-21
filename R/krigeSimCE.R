## Benedikt Gräler (52North), 2018-05-25:
## circulant embedding following: Davies, Tilman M., and David Bryant. "On
## circulant embedding for Gaussian random fields in R." Journal of Statistical
## Software 55.9 (2013): 1-21.
## See i.e. the suplementary files at (retreived 2018-05-25): 
## https://www.jstatsoft.org/index.php/jss/article/downloadSuppFile/v055i09/v55i09.R

# https://github.com/r-spatial/gstat/blob/5dbe096f58497cb1795907ece4451a4cc82d52be/R/krige0.R#L28
.extractFormula = function(formula, data, newdata) {
  # extract y and X from data:
  m = model.frame(terms(formula), as(data, "data.frame"), na.action = na.fail)
  y = model.extract(m, "response")
  if (length(y) == 0)
    stop("no response variable present in formula")
  Terms = attr(m, "terms")
  X = model.matrix(Terms, m)
  
  # extract x0 from newdata:
  terms.f = delete.response(terms(formula))
  mf.f = model.frame(terms.f, newdata) #, na.action = na.action)
  x0 = model.matrix(terms.f, mf.f)
  list(y = y, X = X, x0 = x0)
}

.CHsolve = function(A, b) {
  # solves A x = b for x if A is PD symmetric
  #A = chol(A, LINPACK=TRUE) -> deprecated
  A = chol(A) # but use pivot=TRUE?
  backsolve(A, forwardsolve(A, b, upper.tri = TRUE, transpose = TRUE))
}

# https://github.com/r-spatial/gstat/blob/5dbe096f58497cb1795907ece4451a4cc82d52be/R/circEmbed.R#L153
# extend the grid 
# input: SpatialGrid/SpatialPixels/GridTopology
# output: extended grid of class GridTopology
.ceExtGrid <- function(grid, ext=2) {
  if (!inherits(grid, "GridTopology")) {
    stopifnot(sp::gridded(grid))
    
    grid <- grid@grid
  }
  
  sp::GridTopology(grid@cellcentre.offset,
               grid@cellsize,
               grid@cells.dim*ext)
}

# only for comaprission following the above paper
# expand and wrap a grid on a torus + calc distances
# input: SpatialGrid
# output: distance matrix
.ceWrapOnTorusCalcDist <- function(grid, ext=2) {
  grid <- .ceExtGrid(grid, ext)
  
  rangeXY <- grid@cellsize * grid@cells.dim
  
  MN.ext <- prod(grid@cells.dim)
  gridCoords <- sp::coordinates(grid)
  
  mmat.ext <- matrix(rep(gridCoords[, 1], MN.ext), MN.ext, MN.ext)
  nmat.ext <- matrix(rep(gridCoords[, 2], MN.ext), MN.ext, MN.ext)
  
  mmat.diff <- mmat.ext - t(mmat.ext)
  nmat.diff <- nmat.ext - t(nmat.ext)
  
  mmat.torus <- pmin(abs(mmat.diff), rangeXY[1] - abs(mmat.diff))
  nmat.torus <- pmin(abs(nmat.diff), rangeXY[2] - abs(nmat.diff))
  
  sqrt(mmat.torus^2 + nmat.torus^2)
}

## FFT preparation with only first row of cov-matrix
.ceWrapOnTorusCalcCovRow1 <- function(grid, vgmModel, ext=2) {
  grid <- .ceExtGrid(grid, ext)
  
  stopifnot("variogramModel" %in% class(vgmModel))
  
  rangeXY <- grid@cellsize * grid@cells.dim
  
  cenX <- seq(from = grid@cellcentre.offset[1],
              by = grid@cellsize[1],
              length.out = grid@cells.dim[1])
  cenY <- seq(from = grid@cellcentre.offset[2],
              by = grid@cellsize[2],
              length.out = grid@cells.dim[2])
  
  m.diff.row1 <- abs(cenX[1] - cenX)
  m.diff.row1 <- pmin(m.diff.row1, rangeXY[1] - m.diff.row1)
  
  n.diff.row1 <- abs(cenY[1] - cenY)
  n.diff.row1 <- pmin(n.diff.row1, rangeXY[2] - n.diff.row1)
  
  cent.ext.row1 <- expand.grid(m.diff.row1, n.diff.row1)
  D.ext.row1 <- matrix(sqrt(cent.ext.row1[, 1]^2 + cent.ext.row1[, 2]^2), 
                       grid@cells.dim[1], 
                       grid@cells.dim[2])
  
  gstat::variogramLine(vgmModel, dist_vector = D.ext.row1, covariance = TRUE)
}

# simulate GRF with given covariance structure using fft
# @input
#   covMatRow1: the first row of the covariance matrix for the fft
#   n: number of simulations
#   cells.dim: the original dimrensions of the grid to clip from the larger embedded simulation
#   grid.index: grid.index of a SpatialPixels object to select the right pixels from the larger square-grid
# @output
#   matrix where each column holds one simulated GRF corresponding to cells.dim (and grid.index if appropriate)
.ceSim <- function(covMatRow1, n=1, cells.dim, grid.index) {
  d <- dim(covMatRow1)
  dp <- prod(d)
  sdp <- sqrt(dp)
  # prefix <- sqrt(Re(fft(covMatRow1, TRUE)))
  prefix <- sqrt(fft(covMatRow1, TRUE))
  
  simFun <- function(x) {
    std <- rnorm(dp)
    realz <- prefix * (fft(matrix(std, d[1], d[2]))/sdp)
    as.numeric(Re(fft(realz, TRUE)/sdp)[1:cells.dim[1], 1:cells.dim[2]])
  }
  
  simFunGridIndex <- function(x) {
    std <- rnorm(dp)
    realz <- prefix * (fft(matrix(std, d[1], d[2]))/sdp)
    as.numeric(Re(fft(realz, TRUE)/sdp)[1:cells.dim[1], 1:cells.dim[2]])[grid.index]
  }
  
  if (missing(grid.index))
    do.call(cbind, lapply(1:n, simFun))
  else
    do.call(cbind, lapply(1:n, simFunGridIndex))
}

# computes the covariance matrixes and weights once, applied to series of
# variables/simulations where each variable/simulation is stored in one column of
# the multiVarMatrix copied from krige0 to avoid repeted calls to krige with
# multiple, identical inversions of the weights matrix

.krigeMultiple <- function(formula, from, to, model, multiVarMatrix) {
  lst = .extractFormula(formula, from, to)
  X = lst$X
  x0 = lst$x0
  ll = (!is.na(sp::is.projected(from)) && !sp::is.projected(from))
  s = sp::coordinates(from)
  s0 = sp::coordinates(to)
  
  V = gstat::variogramLine(model,
                    dist_vector = sp::spDists(s, s, ll),
                    covariance = TRUE)
  v0 = gstat::variogramLine(model,
                     dist_vector = sp::spDists(s, s0, ll),
                     covariance = TRUE)
  
  skwts = .CHsolve(V, cbind(v0, X))
  ViX = skwts[, -(1:nrow(s0))]
  skwts = skwts[, 1:nrow(s0)]
  
  idPredFun <- function(sim) {
    sim <- matrix(sim, ncol = 1)
    beta = solve(t(X) %*% ViX, t(ViX) %*% sim)
    x0 %*% beta + t(skwts) %*% (sim - X %*% beta)
  }
  
  apply(multiVarMatrix, 2, idPredFun)
}

# @input: 
# formula: definition of the dependent variable
# data:    optional Spatial*DataFrame for conditional simulation
# newdata: SpatialGrid or SpatialPixels
# model:   variogram model of the GRF
# n:       number of desired simulations
# ext:     extension degree of the circulant embedding, default to 2
# @output
# SpatialPixels or SpatailGridDataFrame with (additional) n columns holding one (un)conditional simulation each

.krigeSimCE <- function(formula, data, newdata, model, n = 1, ext = 2) {
  stopifnot(is(model, "variogramModel"))
  stopifnot(sp::gridded(newdata))
  if (!missing(data))
    stopifnot(identical(data@proj4string@projargs, newdata@proj4string@projargs))
  
  varName <- all.vars(formula[[2]])
  
  condSim <- TRUE
  if (missing(data)) {
    condSim <- FALSE
    #message("[No data provided: performing unconditional simulation.]")
  } else {
    #message("[Performing conditional simulation.]")
  }
  
  # prepare covariance matrix
  covMat <- .ceWrapOnTorusCalcCovRow1(newdata, model, ext = ext)
  # covMat <- Matrix::nearPD(covMat) # ARREGLO
  
  # simulate
  sims <- .ceSim(covMat, n, newdata@grid@cells.dim, newdata@grid.index)
  colnames(sims) <- paste0(varName, ".sim", 1:n)
  
  # bind simulations to newdata geometry
  if (!condSim) {
    if ("data" %in% slotNames(newdata))
      newdata@data <- cbind(newdata@data, sims)
    else
      sp::addAttrToGeom(newdata, as.data.frame(sims))
    return(newdata)
  }
  
  # function call ends here if no data has been provided -> unconditional case
  
  ## conditioning
  # interpolate the observations to the simulation grid
  obsMeanField <- gstat::krige(formula, data, newdata, model)
  
  # interpolate to observation locations from the simulated grids for each simulation
  simMeanObsLoc <- .krigeMultiple(as.formula(paste0("var1.pred ~", formula[[3]])),
                                 obsMeanField, data, model, sims)
  
  # interpolate from kriged mean sim at observed locations back to the grid for mean surface of the simulations
  simMeanFields <- .krigeMultiple(as.formula(paste0(varName, "~", formula[[3]])),
                                 data, newdata, model, simMeanObsLoc)
  
  # add up the mean field and the corrected data
  sims <- obsMeanField@data$var1.pred + sims - simMeanFields
  
  # bind simulations to newdata geometry
  if ("data" %in% methods::slotNames(newdata)) {
    newdata@data <- cbind(newdata@data, sims)
    return(newdata)
  }
  
  sp::addAttrToGeom(newdata, as.data.frame(sims))
}

.DD <- function(expr, names, order = 1, debug=FALSE) {
  if (any(order>=1)) {  ## do we need to do any more work?
    w <- which(order>=1)[1]  ## find a derivative to compute
    if (debug) {
      cat(names,order,w,"\n")
    }
    ## update order
    order[w] <- order[w]-1
    ## recurse ...
    return(.DD(D(expr,names[w]), names, order, debug))
  }
  return(expr)
}

