
#' Get basis statistics for the graph
#'
#' @param graph a \code{graph} object.
#'
#' @return
#' Returns a list with the number of vertices (\code{nvertices}), 
#' and the number of edges (\code{nedges}). When the graph has already
#' been freed an empty list is returned.
#' 
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
graph_stats <- function(graph) {
  stats <- stats_rcpp(graph)
  if (length(stats) == 0) return(list())
  list(
    nvertices = as.integer(stats["nvertices"]),
    nedges = as.integer(stats["nedges"])
  )
}

