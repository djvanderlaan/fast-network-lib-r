

#' Calculate local average over vertex values in the area around each vertex
#'
#' @param graph a graph object. Note that is possible that the graph is
#' modified see details. 
#' @param values numeric vector with vertex values. Should have the same length
#' as the number of vertices. 
#' @param weights numeric vector with vertex weights. Should have the same length
#' as the number of vertices. 
#' @param alpha stopping parameter. Should be between 0 and 1. The lower the
#' value the smaller the area around the ego vertex.
#' @param nstep_max the maximum number of iterations. 
#' @param precision the iterations will stop when all changes in the results are
#' smaller than the precision. 
#' @param nthreads number of threads to use. Values of 0 and 1 mean that the
#' computation is performed in the main thread. 
#' @param normalise_weights make sure the weights of the outgoing edges of all
#' vertices sum to one. See details.
#'
#' @details
#' Before the computation, the edge weights are normalised: it is made sure that
#' the sum of the outgoing weights add up to one for each vertex. This changes
#' the original weights of the graph. Setting the option \code{normalise_weights}
#' to \code{FALSE} prevents this. However, if the weights do not add up to one 
#' the algorithm will give incorrect resuts.
#'
#' @return
#' Returns a numeric vector with the local average of each vertex. Values of
#' \code{NaN} indicate that the corresponding vertex did not have any
#' neighbourd. The vector has an attribute "nstep" with the number of iterations
#' the computation took. 
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
localised_random_walk <- function(graph, values, weights, alpha = 0.85, nstep_max = 200, 
    precision = 1E-5, nthreads = 0, normalise_weights = TRUE) {
  nvertices = graph_stats(graph)$nvertices
  stopifnot(length(values) == nvertices)
  stopifnot(length(weights) == nvertices)
  stopifnot(!anyNA(values))
  stopifnot(!anyNA(weights))
  stopifnot(length(alpha) == 1 && !is.na(alpha) && alpha > 0 && alpha < 1)
  stopifnot(length(nstep_max) == 1 && !is.na(nstep_max) && nstep_max >= 1)
  stopifnot(length(precision) == 1 && !is.na(precision) && precision > 0)
  stopifnot(length(nthreads) == 1 && !is.na(nthreads) && nthreads >= 0)
  res <- localised_random_walk_rcpp(graph, values, weights, alpha, nstep_max, 
    precision, nthreads, normalise_weights)
  if (attr(res, "nstep") == nstep_max) 
    warning("Algorithm did not converge to specified precision.")
  res
}

