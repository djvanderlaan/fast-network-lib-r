#' Get the edges from a graph object
#'
#' @param graph a \code{graph} object.
#'
#' @return
#' Will return a \code{data.frame} with the columns \code{src}, \code{dst}, and
#' \code{weights} and optionally \code{layer} containing the source, destination 
#' and weight of the edges.
#' 
#' Note that unlike \code{\link{get_edgelist}} the \code{src} and \code{dst} 
#' columns are values from \code{vertices(graph)}. 
#' 
#' @seealso
#' \code{\link{get_edgelist}} returns the indices of edges; 
#' \code{\link{vertices}} returns the vertex ids. 
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
edges <- function(graph) {
  res <- get_edgelist(graph)
  v <- vertices(graph)
  res$src <- v[res$src]
  res$dst <- v[res$dst]
  res
}