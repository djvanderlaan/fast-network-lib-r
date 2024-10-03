#' Create a graph object
#' 
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
create_graph <- function(vertex_ids, src, dst, weights = NULL, layer = NULL) {
  stopifnot(!anyDuplicated(vertex_ids))
  # Create empty graph
  res <- create_graph_rcpp(length(vertex_ids), src = integer(0), 
    dst = integer(0))
  # Add edges
  add_edges(graph = res, vertex_ids = vertex_ids, src = src, dst = dst,
    weights = weights, layer = layer)
  structure(res, class = "graph", vertex_ids = vertex_ids)
}

