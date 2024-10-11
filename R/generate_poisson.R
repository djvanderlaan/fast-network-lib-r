#' Generate a Poisson Random Graph
#'
#' @param nvertices number of vertices in graph.
#' @param mean_degree mean degree of the graph
#' @param seed the seed for the internal random generator (should be a positive
#'   integer between 0 and .Machine#integer.max).
#'
#' @return
#' Return a graph object. See \code{\link{create_graph}} for more details. 
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
generate_poisson <- function(nvertices, mean_degree, 
    seed = sample(.Machine$integer.max, 1)) {
  stopifnot(length(nvertices) == 1)
  stopifnot(!is.na(nvertices))
  stopifnot(nvertices >= 0 && nvertices <= .Machine$integer.max)
  stopifnot(length(mean_degree) == 1)
  stopifnot(!is.na(mean_degree))
  stopifnot(mean_degree >= 0)
  stopifnot(length(seed) == 1)
  stopifnot(!is.na(seed))
  stopifnot(seed >= 0 && seed <= .Machine$integer.max)
  graph <- generate_poisson_rcpp(nvertices, mean_degree, seed)
  structure(graph, class = "graph", vertex_ids = seq_len(nvertices))
}

