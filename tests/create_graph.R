# Here we also test free_graph, free_all_graphs and graph_stats

source("helpers.R")

library(fastnetworklib)

nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats, list("nvertices"=10L, "nedges"=7L))
stats <- graph_stats(g)
expect_equal(stats, list())

# No edges -> every vertex in its own component
nvert <- 10
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats, list("nvertices"=10L, "nedges"=0L))
stats <- graph_stats(g)
expect_equal(stats, list())

# Empty graph
nvert <- 0
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats, list("nvertices"=0L, "nedges"=0L))
stats <- graph_stats(g)
expect_equal(stats, list())

# Free all
nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
g1 <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
nvert <- 0
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g2 <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
stats <- graph_stats(g1)
expect_equal(stats, list("nvertices"=10L, "nedges"=7L))
stats <- graph_stats(g2)
expect_equal(stats, list("nvertices"=0L, "nedges"=0L))
free_all_graphs()
stats <- graph_stats(g1)
expect_equal(stats, list())
stats <- graph_stats(g2)
expect_equal(stats, list())


# Test ordered option
nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
expect_error(
  g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst, ordered = TRUE)
)
edges <- edges[order(edges$src),]
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst, ordered = TRUE)
res <- get_edgelist(g)
free_graph(g)
expect_equal(res[[1]], edges[[1]]+1L)
expect_equal(res[[2]], edges[[2]]+1L)

