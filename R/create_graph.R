#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
create_graph <- function(vertex_ids, src, dst) {
  stopifnot(!anyDuplicated(vertex_ids))
  src <- match(src, vertex_ids) - 1L
  dst <- match(dst, vertex_ids) - 1L
  stopifnot(!anyNA(src))
  stopifnot(!anyNA(dst))
  o <- order(src)
  src <- src[o]
  dst <- dst[o]
  res <- create_graph_rcpp(length(vertex_ids), src, dst)
  structure(res, class = "graph")
}
