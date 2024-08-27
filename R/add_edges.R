
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
add_edges <- function(graph, vertex_ids, src, dst, weights = NULL) {
  stopifnot(!anyDuplicated(vertex_ids))
  stopifnot(length(src) == length(dst))
  stopifnot(is.null(weights) || length(weights) == length(src))
  src <- match(src, vertex_ids) - 1L
  dst <- match(dst, vertex_ids) - 1L
  stopifnot(!anyNA(src))
  stopifnot(!anyNA(dst))
  stopifnot(is.null(weights) || !anyNA(weights))
  if (!is.null(weights)) {
    add_edgesw_rcpp(graph, src, dst, weights)
  } else {
    add_edges_rcpp(graph, src, dst)
  }
  invisible(graph)
}

