#' Create a graph object
#' 
#' @param vertex_ids a vector with the id's of the vertices of the graph.
#' @param src vector with the source vertex id of the edges. Should be values present
#'   in \code{vertex_ids}. 
#' @param dst vector with the destination vertex id of the edges. Should be values present
#'   in \code{vertex_ids}. Should have the same length as \code{src}.
#' @param weights optional vector with the weights of the edges. When omitted als edges
#'   get a weight of 1.0. Should have the same length as \code{src} (or \code{NULL}).
#' @param ordered logical indicating whether or not the edges are ordered. Passing
#'   \code{TRUE} when the edges are ordered can speed up creation of the graph.
#'
#' @details
#' Graphs are always considered to be directed weighted graphs.
#'
#' @return
#' Returns a graph object. This is an integer value indicating the internal id of the 
#' graph in the fast-network-lib library. Make sure to delete the graph using 
#' \code{\link{free_graph}} or \code{\link{free_all_graphs}} after use, to free up the 
#' memory associated with the graph.
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
create_graph <- function(vertex_ids, src, dst, weights = NULL, ordered = FALSE) {
  stopifnot(!anyDuplicated(vertex_ids))
  stopifnot(length(src) == length(dst))
  stopifnot(missing(weights) || length(weights) == length(src))
  src <- match(src, vertex_ids) - 1L
  dst <- match(dst, vertex_ids) - 1L
  stopifnot(!anyNA(src))
  stopifnot(!anyNA(dst))
  stopifnot(missing(weights) || !anyNA(weights))
  if (!ordered) {
    o <- order(src)
    src <- src[o]
    dst <- dst[o]
    if (!missing(weights)) {
      weights <- weights[o]
    }
  }
  if (!missing(weights)) {
    res <- create_graphw_rcpp(length(vertex_ids), src, dst, weights)
  } else {
    res <- create_graph_rcpp(length(vertex_ids), src, dst)
  }
  structure(res, class = "graph")
}

