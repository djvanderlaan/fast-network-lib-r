
#' Read and write graph from and to file in pajek format
#'
#' @param graph the graph to write.
#' @param filename the filename to write to or read from.
#'
#' @details
#' The graph is stored in pajek format as a directed weighted graph. It is 
#' possible to store vertex information in pajek format (e.g. vertex labels)
#' this information is not used by fastnetworklib and therefore ignored. 
#' 
#' @return 
#' \code{read_pajek} returns the graph as a \code{graph} object. 
#' 
#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @rdname pajek
#' @export
write_pajek <- function(graph, filename) {
  write_pajek_rcpp(graph, filename)
  invisible(graph)
}

#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @rdname pajek
#' @export
read_pajek <- function(filename) {
  stopifnot(file.exists(filename))
  graph <- read_pajek_rcpp(filename)
  structure(graph, class = "graph")
}

