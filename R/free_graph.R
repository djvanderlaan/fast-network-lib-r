#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
free_graph <- function(graph) {
  free_graph_rcpp(graph)
  invisible(NULL)
}

#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
free_all_graphs <- function() {
  free_allgraphs_rcpp()
  invisible(NULL)
}
