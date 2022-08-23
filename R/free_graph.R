#' Delete the graph from memory
#'
#' @param graph a \code{graph} object.
#'
#' @details
#' \code{free_all_graphs} will delete all graphs from memory.
#'
#' @return
#' Does not return anything. Called for its side effect of freeing memory. 
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @rdname free_graph
#' @export
free_graph <- function(graph) {
  free_graph_rcpp(graph)
  invisible(NULL)
}

#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @rdname free_graph
#' @export
free_all_graphs <- function() {
  free_all_graphs_rcpp()
  invisible(NULL)
}
