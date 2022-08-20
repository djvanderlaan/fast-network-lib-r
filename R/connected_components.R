#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
connected_components <- function(graph) {
  connected_components_rcpp(graph)
}
