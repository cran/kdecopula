bern_poly <- function(x, k, m) {
    (choose(m, k) * x^k * (1 - x)^(m - k)) * (m + 1)
}

bern_coefs <- function(u, m) {
    # initialize coefficients with empirical frequencies
    ucut <- apply(u, 2, function(x) cut(x, 0:(m + 1) / (m + 1)))
    cf0 <- table(ucut[, 1], ucut[, 2]) / nrow(u)
    
    # set up quadratic programming problem
    m <- m + 1
    D <- diag(m^2)
    d <- as.vector(cf0)
    A1 <- A2 <- matrix(0, m, m^2)
    for (i in 1:m) {
        A1[i, (i - 1) * m + 1:m] <- 1
        A2[i, m * (1:m) - m + i] <- 1
    }
    A3 <- diag(m^2)
    A <- t(rbind(A1, A2, A3))
    b <- c(rep(1 / m, 2 * m), rep(0, m^2))
    
    # solve
    sol <- tryCatch(solve.QP(D, d, A, b, meq = 2 * m)$solution,
                    error = function(e) d)
    sol[sol < 0] <- 0
    
    # return as matrix
    matrix(sol, m, m)
}

berncop <- function(u, m = 10) {
    out <- list(coefs = bern_coefs(u, m),
                m = m)
    class(out) <- "berncop"
    out
}


dberncop <- function(unew, object, ...) {
    list2env(object)
    summand <- function(i, j) {
        P1 <- bern_poly(unew[, 1], i, object$m)
        P2 <- bern_poly(unew[, 2], j, object$m)
        object$coefs[i + 1, j + 1] * P1 * P2
    }
    
    est <- 0
    for (i in 0:object$m) {
        est <- est + rowSums(sapply(0:object$m, function(j) summand(i, j)))
    }
    est
}