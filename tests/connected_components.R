source("helpers.R")

library(fastnetworklib)


nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
a <- connected_components(g)
free_graph(g)
expect_equal(a, c(0,1,1,1,1,5,6,6,6,6))

# No edges -> every vertex in its own component
nvert <- 10
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
a <- connected_components(g)
free_graph(g)
expect_equal(a, seq(0, 9))

# Empty graph
nvert <- 0
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
a <- connected_components(g)
free_graph(g)
expect_equal(a, integer(0))

# Components of deleted graph
expect_error(connected_components(g))

