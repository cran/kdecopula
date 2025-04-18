% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.kdecopula.R
\name{plot.kdecopula}
\alias{plot.kdecopula}
\alias{contour.kdecopula}
\title{Plotting \code{kdecopula} objects}
\usage{
\method{plot}{kdecopula}(x, type = "surface", margins, size, ...)

\method{contour}{kdecopula}(x, margins = "norm", size = 100L, ...)
}
\arguments{
\item{x}{\code{kdecopula} object.}

\item{type}{plot type; either \code{"contour"} or \code{"surface"} (partial
matching is activated) for a contour or perspective/surface plot
respectively.}

\item{margins}{\code{"unif"} for the original copula density,
\code{"norm"} for the transformed density with standard normal margins,
\code{"exp"} with standard exponential margins, and  \code{"flexp"} with
flipped exponential margins. Default is \code{"norm"} for \code{type =
"contour"}, and \code{"unif"} for \code{type = "surface"}.}

\item{size}{integer; the plot is based on values on a \eqn{size x size}
grid; default is 100 for \code{type = "contour"}, and 25 for \code{type =
"surface"}.}

\item{\dots}{optional arguments passed to \code{\link[graphics:contour]{contour}}
or \code{\link[lattice:wireframe]{wireframe}}.}
}
\description{
Produces perspective or contour plots for a \code{kdecopula} object.
}
\examples{

## load data and transform with empirical cdf
data(wdbc)
udat <- apply(wdbc[, -1], 2, function(x) rank(x)/(length(x)+1))

## estimation of copula density of variables 5 and 6
obj <- kdecop(udat[, 5:6])

## plots
plot(obj)  # surface plot of copula density
contour(obj)  # contour plot with standard normal margins
contour(obj, margins = "unif")  # contour plot of copula density

}
\references{
Nagler, T. (2018)
kdecopula: An R Package for the Kernel Estimation of Bivariate Copula
Densities.
Journal of Statistical Software 84(7), 1-22
}
\seealso{
\code{\link[kdecopula:kdecop]{kdecop}},
\code{\link[graphics:contour]{contour}},
\code{\link[lattice:wireframe]{wireframe}}
}
\author{
Thomas Nagler
}
\keyword{plot}
