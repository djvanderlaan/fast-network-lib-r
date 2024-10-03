
#' Get the edge list as a data.frame from a graph object
#'
#' @param graph a \code{graph} object.
#'
#' @return
#' Will return a \code{data.frame} with the columns \code{src}, \code{dst}, and
#' \code{weights} containing the source, destination and weight of the edges.
#' Note that the ids in \code{src} and \code{dst} are the indices into the
#' original vertices supplied in \code{\link{create_graph}}. 
#' 
#' @seealso
#' \code{\link{edges}} to get the edge list with the ids of the vertices instead
#' of the indices.
#'
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
get_edgelist <- function(graph) {
  get_edgelist_rcpp(graph)
}

