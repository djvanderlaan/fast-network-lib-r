#' @useDynLib fastnetworklib
#' @import Rcpp
#' @importFrom Rcpp evalCpp
#' @export
create_graph <- function(vertex_ids, src, dst, weights = NULL) {
  stopifnot(!anyDuplicated(vertex_ids))
  stopifnot(length(src) == length(dst))
  stopifnot(missing(weights) || length(weights) == length(src))
  src <- match(src, vertex_ids) - 1L
  dst <- match(dst, vertex_ids) - 1L
  stopifnot(!anyNA(src))
  stopifnot(!anyNA(dst))
  stopifnot(missing(weights) || !anyNA(weights))
  o <- order(src)
  src <- src[o]
  dst <- dst[o]
  if (!missing(weights)) {
    weights <- weights[o]
    res <- create_graphw_rcpp(length(vertex_ids), src, dst, weights)
  } else {
    res <- create_graph_rcpp(length(vertex_ids), src, dst)
  }
  structure(res, class = "graph")
}
