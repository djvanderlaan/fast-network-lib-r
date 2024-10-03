#' Determine layer contributions for localised random walk
#'
#' Decompose the results for the localised random walk into direct and indirect
#' components for each layer
#'
#' @param graph a graph object. Note that is possible that the graph is
#' modified see details. 
#' @param values numeric vector with vertex values. Should have the same length
#' as the number of vertices. 
#' @param exposure numeric vector with the exposure values obtained from 
#' \code{\link{localised_random_walk}}. Should have the same length as the
#' number of vertices. 
#' @param weights numeric vector with vertex weights. Should have the same length
#' as the number of vertices. 
#' @param alpha stopping parameter. Should be between 0 and 1. The lower the
#' value the smaller the area around the ego vertex. Should be the same as the
#' values used prviously in the \code{\link{localised_random_walk}}.
#'
#' @return 
#' Returns a \code{data.frame} with the direct and indirect effect of each
#' layer for each vertex. It contains the following columns:
#'
#' \describe{
#'   \item{id}{The id of the vertex}
#'   \item{layer}{The layer id. These are numbered from 1 to the number of
#'   layers.}
#'   \item{direct}{The direct effect of the layer for the given vertex.}
#'   \item{indirect}{The indirect effect of the layer for the given vertex.}
#' }
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#'@export
decompose_exposure <- function(graph, values, exposure, weights = 1.0, 
    alpha = 0.85) {
  nvertices = graph_stats(graph)$nvertices
  # check input 
  stopifnot(length(values) == nvertices && is.numeric(exposure))
  stopifnot(!anyNA(values))
  if (length(weights) == 1 && is.numeric(weights)) 
    weights <- rep(weights, nvertices)
  stopifnot(length(weights) == nvertices && is.numeric(exposure))
  stopifnot(!anyNA(weights))
  stopifnot(length(exposure) == nvertices && is.numeric(exposure))
  #stopifnot(!anyNA(exposure))
  stopifnot(length(alpha) == 1 && !is.na(alpha) && alpha > 0 && alpha < 1)
  # call fastnetworklib
  d <- decompose_exposure_rcpp(graph, values, exposure, weights, alpha)
  # transform 
  nlayers <- length(d)/2
  result <- lapply(seq_len(nlayers), function(l) {
    data.frame(id = vertices(graph), layer = l, direct = d[[l]], 
      indirect = d[[nlayers+l]])
  })
  do.call(rbind, result)
}
