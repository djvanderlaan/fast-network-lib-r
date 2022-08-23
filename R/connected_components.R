

#' Calculate connected components of graph
#'
#' @param graph a graph object.
#'
#' @details
#' For calculating the components the network is considered as an undirected 
#' unweighted network.
#'
#' @return
#' Returns an integer vector with the same length as the number of vertices,
#' indicating to which component each vertex belongs. Each separate number is 
#' a separate components. 
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
connected_components <- function(graph) {
  connected_components_rcpp(graph)
}

