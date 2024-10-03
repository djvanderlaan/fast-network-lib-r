
#' Add edges to graph object
#' 
#' @param graph a \code{graph} object.
#' @param vertex_ids a vector with the id's of the vertices of the graph.
#' @param src vector with the source vertex id of the edges. Should be values present
#'   in \code{vertex_ids}. 
#' @param dst vector with the destination vertex id of the edges. Should be values present
#'   in \code{vertex_ids}. Should have the same length as \code{src}.
#' @param weights optional vector with the weights of the edges. When omitted als edges
#'   get a weight of 1.0. Should have the same length as \code{src} (or \code{NULL}).
#' @param layer optional vector with the layer to which each edge belongs. Should
#'   have the same length as \code{src} (or \code{NULL}) and should contain 
#'   integer values between 1 and 255. 
#'
#' @details
#' It is assumed that edges are added in order. If the edges of vertices 1 to 10
#' are already added to the graph, \code{add_edges} will generate an error when
#' an attempt is made to add edges of vertices 1 to 9. 
#'
#' @return
#' Returns the graph object. 
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
add_edges <- function(graph, vertex_ids, src, dst, weights = NULL, layer = NULL) {
  stopifnot(!anyDuplicated(vertex_ids))
  stopifnot(length(src) == length(dst))
  stopifnot(is.null(weights) || length(weights) == length(src))
  stopifnot(is.null(layer) || length(layer) == length(src))
  src <- match(src, vertex_ids) - 1L
  dst <- match(dst, vertex_ids) - 1L
  stopifnot(!anyNA(src))
  stopifnot(!anyNA(dst))
  stopifnot(is.null(weights) || !anyNA(weights))
  stopifnot(is.null(layer) || !anyNA(layer))
  stopifnot(is.null(layer) || all(layer > 0 & layer < 256))
  if (is.unsorted(src)) {
    o <- order(src)
    src <- src[o]
    dst <- dst[o]
    if (!is.null(weights)) weights <- weights[o]
    if (!is.null(layer)) layer <- layer[o]
  }
  add_edgesl_rcpp(graph, src, dst, weights, layer)
  invisible(graph)
}

