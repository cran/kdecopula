#' Plotting \code{kdecopula} objects
#'
#' Produces perspective or contour plots for a \code{kdecopula} object.
#'
#' @method plot kdecopula
#'
#' @aliases plot.kdecopula contour.kdecopula
#' @param x \code{kdecopula} object.
#' @param type plot type; either \code{"contour"} or \code{"surface"} (partial
#' matching is activated) for a contour or perspective/surface plot
#' respectively.
#' @param margins \code{"unif"} for the original copula density,
#' \code{"norm"} for the transformed density with standard normal margins,
#' \code{"exp"} with standard exponential margins, and  \code{"flexp"} with
#' flipped exponential margins. Default is \code{"norm"} for \code{type =
#' "contour"}, and \code{"unif"} for \code{type = "surface"}.
#' @param size integer; the plot is based on values on a \eqn{size x size}
#' grid; default is 100 for \code{type = "contour"}, and 25 for \code{type =
#' "surface"}.
#' @param \dots optional arguments passed to \code{\link[graphics:contour]{contour}} 
#' or \code{\link[lattice:wireframe]{wireframe}}.
#'
#'
#' @author Thomas Nagler
#' 
#' @references 
#' Nagler, T. (2018)
#' kdecopula: An R Package for the Kernel Estimation of Bivariate Copula 
#' Densities. 
#' Journal of Statistical Software 84(7), 1-22
#'
#' @seealso \code{\link[kdecopula:kdecop]{kdecop}},
#' \code{\link[graphics:contour]{contour}},
#' \code{\link[lattice:wireframe]{wireframe}}
#'
#' @keywords plot
#'
#' @examples
#'
#' ## load data and transform with empirical cdf
#' data(wdbc)
#' udat <- apply(wdbc[, -1], 2, function(x) rank(x)/(length(x)+1))
#'
#' ## estimation of copula density of variables 5 and 6
#' obj <- kdecop(udat[, 5:6])
#'
#' ## plots
#' plot(obj)  # surface plot of copula density
#' contour(obj)  # contour plot with standard normal margins
#' contour(obj, margins = "unif")  # contour plot of copula density
#' 
#' @importFrom utils modifyList
#' @importFrom stats dexp pexp qexp
#'
#' @export
plot.kdecopula <- function(x, type = "surface", margins, size, ...) {
    if (length(dim(x$estimate)) > 2)
        stop("Plotting is only available for 2-dimensional densities.")

    ## partial matching and sanity check for type
    stopifnot(class(type) == "character")
    tpnms <- c("contour", "surface")
    type <- tpnms[pmatch(type, tpnms)]
    if (is.na(type))
        stop("type not implemented")

    ## choose margins if missing, else partial matching and sanity check
    if (missing(margins)) {
        margins <- switch(type,
                          "contour" = "norm",
                          "surface" = "unif")
    } else {
        stopifnot(class(margins) == "character")
        mgnms <- c("norm", "unif", "exp", "flexp")
        margins <- mgnms[pmatch(margins, mgnms)]
    }

    ## choose size if missing and sanity check
    if (missing(size))
        size <- switch(type,
                       "contour" = 100L,
                       "surface" = 20L)
    stopifnot(is.numeric(size))
    size <- round(size)

    ## construct grid for evaluation of the copula density
    if (size < 5) {
        warning("size too small, set to 5")
        size <- 5
    }
    if (!(margins %in% c("unif", "norm", "exp", "flexp")))
        stop("'margins' has to be one of 'unif', 'norm', 'exp', or 'flexp'.")
    if (is.null(list(...)$xlim) & is.null(list(...)$ylim)) {
        xylim <- switch(margins,
                        "unif"  = c(1e-2, 1 - 1e-2),
                        "norm"  = c(-3, 3),
                        "exp"   = c(0, 6),
                        "flexp" = c(-6, 0))
    } else {
        xylim <- range(c(list(...)$xlim, list(...)$ylim))
    }

    ## prepare for plotting with selected margins
    if (margins == "unif") {
        points <- switch(type,
                         "contour"  = seq(1e-5, 1 - 1e-5, length.out = size),
                         "surface"  = 1:size / (size + 1))
        g <- as.matrix(expand.grid(points, points))
        points <- g[1L:size, 1L]
        adj <- 1
        gu <- g[, 1L]
        gv <- g[, 2L]
        levels <- c(0.2, 0.6, 1, 1.5, 2, 3, 5, 10, 20)
        xlim <- ylim <- xylim
        at <- c(seq(0, 3, length.out = 50), seq(5, 100, length.out = 50))
    } else if (margins == "norm") {
        points <- pnorm(seq(xylim[1L], xylim[2L], length.out = size))
        g <- as.matrix(expand.grid(points, points))
        points <- qnorm(g[1L:size, 1L])
        adj <- tcrossprod(dnorm(points))
        levels <- c(0.01, 0.025, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5)
        gu <- qnorm(g[, 1L])
        gv <- qnorm(g[, 2L])
        xlim <- ylim <- xylim
        at <- c(seq(0, 0.3, length.out = 50), seq(0.3, 100, length.out = 50))
    } else if (margins == "exp") {
        ll <- ifelse(type == "contour", 1e-2, 1e-1)
        points <- pexp(seq(ll, xylim[2L], length.out = size))
        g <- as.matrix(expand.grid(points, points))
        points <- qexp(g[1L:size, 1L])
        adj <- tcrossprod(dexp(points))
        levels <- c(0.005, 0.01, 0.025, 0.05, 0.1, 0.2, 0.3, 0.5)
        gu <- qexp(g[, 1L])
        gv <- qexp(g[, 2L])
        xlim <- ylim <- xylim
        at <- c(0, exp(seq(-10, 0, length.out = 79)), seq(1, 10, length.out = 20))
    } else if (margins == "flexp") {
        ll <- ifelse(type == "contour", 1e-2, 1e-1)
        points <- pexp(-seq(xylim[1L], -ll, length.out = size))
        g <- as.matrix(expand.grid(points, points))
        points <- -qexp(g[1L:size, 1L])
        adj <- tcrossprod(dexp(qexp(g[1L:size, 1L])))
        levels <- c(0.005, 0.01, 0.025, 0.05, 0.1, 0.2, 0.3, 0.5)
        gu <- -qexp(g[, 1L])
        gv <- -qexp(g[, 2L])
        g <- 1 - g
        xlim <- ylim <- xylim
        at <- c(0, exp(seq(-10, 0, length.out = 79)), seq(1, 10, length.out = 20))
    }

    ## evaluate on grid
    vals <- dkdecop(g, x, stable = FALSE)
    cop <- matrix(vals, size, size)

    ## get variable names
    nms <- colnames(x$udata)
    if (length(nms) == 2) {
        xlab <- nms[1]
        ylab <- nms[2]
    } else {
        xlab <- switch(margins,
                       "unif"  = expression(u[1]),
                       "norm"  = expression(z[1]),
                       "exp"   = expression(e[1]),
                       "flexp" = expression(e[1]))
        ylab <- switch(margins,
                       "unif"  = expression(u[2]),
                       "norm"  = expression(z[2]),
                       "exp"   = expression(e[2]),
                       "flexp" = expression(e[2]))
    }

    ## actual plotting
    if (type == "contour") {
        # set default parameters
        pars <- list(x = points,
                     y = points,
                     z = cop * adj,
                     levels = levels,
                     xlim = xlim,
                     ylim = ylim,
                     xlab = xlab,
                     ylab = ylab)

        # call contour with final parameters
        do.call(contour, modifyList(pars, list(...)))
    } else if (type == "heat") {
        stop("Not implemented yet")
    } else if (type == "surface") {
        # list with coordinates
        lst <- list(u = gu, v = gv, c = as.vector(cop) * as.vector(adj))

        # define colors
        TUMblue   <- rgb(0, 103/255, 198/255)

        # set default parameters
        pars <- list(x = c ~ u * v,
                     data = lst,
                     scales = list(arrows = FALSE),
                     drape = TRUE, colorkey = FALSE,
                     screen = list(z = 25, x = -55),
                     shade = FALSE,
                     aspect = c(1, 1),
                     light.source = c(10,0,10),
                     zoom = 0.85,
                     par.settings = list(axis.line = list(col = "transparent")),
                     at = at,
                     col.regions =
                         c(colorRampPalette(c(tint(TUMblue, 0.5), "white"))(50),
                           rep("white", 50)),
                     xlab = list(xlab, rot = 20),
                     ylab = list(ylab, rot = 30 - 90),
                     zlab = "",
                     zlim = switch(margins,
                                   "unif"  = c(0, max(3,   1.1 * max(lst$c))),
                                   "norm"  = c(0, max(0.4, 1.1 * max(lst$c))),
                                   "exp"   = c(0, max(1,   1.1 * max(lst$c))),
                                   "flexp" = c(0, max(1,   1.1 * max(lst$c)))))

                     # call wireframe with final parameters
                     do.call(wireframe, modifyList(pars, list(...)))
    }
}

#' @method contour kdecopula
#' @rdname plot.kdecopula
#' @export
contour.kdecopula <- function(x, margins = "norm", size = 100L, ...) {
    plot(x, type = "contour", margins = margins, size = size, ...)
}

#' Tint a given color
#'
#' @param x color (as input to col2rgb)
#' @param fac tinting factor
#' @param alpha opacity value
#' 
#' @noRd
tint <- function(x, fac, alpha = 1) {
    x <- c(col2rgb(x))
    x <- (x + (255 - x) * fac) / 255
    rgb(x[1], x[2], x[3], alpha)
}

