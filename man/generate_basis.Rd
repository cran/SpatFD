\name{generate_basis}
\alias{generate_basis}
\title{
Creates functional ortogonal basis as fd object.
}
\description{
This function returns the first nth elements of a functional basis as an fd object.
}
\usage{
generate_basis(basis = "Fourier",n_functions = 10,L = NULL,fda_basis = NULL)
}
\arguments{
  \item{basis}{Name of the functional basis. Currently only \code{"Fourier"} or \code{"Legendre"} are supported.}
  \item{n_functions}{Positive integer giving the number of functions that are going to be generated.}
  \item{L}{For \code{"Fourier"} basis, limits of the domain of the basis \eqn{(-L,L)}. For \code{"Legendre"} basis, the domain is \eqn{(-1,1)}.}
  \item{fda_basis}{\code{basisfd} object from package \code{fda} that will be used in the \code{fd} object that is returned. If \code{NULL}, default basis are generated.}
}
\details{

Fourier basis functions are given by:

\deqn{f_k(x) = \sqrt{\frac{2}{L}}\text{sin}\left(\frac{k\pi x}{2L}\right)}

for \eqn{k=2,4,6,...}, and

\deqn{f_k(x) = \sqrt{\frac{2}{L}}\text{cos}\left(\frac{(k + 1)\pi x}{2L}\right)}

for  \eqn{k=1,3,5,...}.

Furthermore, Legendre basis functions are given by:

\deqn{f_k(x) = \frac{1}{2^nn!}\frac{d^n}{dx}(x^2 - 1)^n}

for \eqn{k = 1,2,3,4,...}.


}
\value{
  \code{fda::fd} object with \code{n_functions} curves.
}
\references{
Conway, J. B. (2019). A course in functional analysis (Vol. 96). Springer.
}
\author{
Samuel Sánchez Gutiérrez \email{ssanchezgu@unal.edu.co}.
}
\note{
Generating \eqn{n} Legendre basis functions requires to evaluate \eqn{\frac{n(n+1)}{2}} derivates, so its recomended to use values below 10.
}
\seealso{\code{\link{sim_functional_process}}
}
\examples{
\donttest{
library(fda)

# 10 Fourier functions
res <- generate_basis(L=1)
plot(res)

# 20 Fourier functions
res <- generate_basis(n_functions = 20,L = 3)
plot(res)

# 10 Legendre functions
res <- generate_basis(basis = "Legendre")
plot(res)

# 7 Legendre functions
res <- generate_basis(basis = "Legendre", n_functions = 7)
plot(res)
}
}
