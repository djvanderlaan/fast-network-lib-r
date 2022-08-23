
#' @export
print.graph <- function(x, ...) {
  stats <- graph_stats(x)
  cat("Graph id = ", x, "", sep = "")
  if (length(stats) == 0) {
    cat(" freed.\n")
  } else {
    cat(" #vertices = ", stats$nvertices, 
      " #edges = ", stats$nedges, ".\n", sep ="")
  }
  invisible(x)
}



