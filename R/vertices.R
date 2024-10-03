

#' Get the vertices from a graph object
#'
#' @param graph a \code{graph} object.
#'
#' @return
#' Returns a vector with the ids of the vertices of the graph. 
#' 
#' @seealso
#' \code{\link{edges}} to get the edges of the graph.
#' 
#' @examples
#' vertices <- c("c", "b", "a")
#' edges <- data.frame(
#'   src = c("a", "a", "b"),
#'   dst = c("b", "c", "a")
#' )
#'
#' g <- create_graph(vertices, src = edges$src, dst = edges$dst)
#' edges(g)
#' get_edgelist(g)
#'
#' @export
vertices <- function(graph) {
  attr(graph, "vertex_ids")
}