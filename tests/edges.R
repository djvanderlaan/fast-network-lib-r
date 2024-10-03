
library(fastnetworklib)
source("helpers.R")


# ==============================================================================

vertices <- c("c", "b", "a")
edges <- data.frame(
  src = c("a", "a", "b"),
  dst = c("b", "c", "a")
)

g <- create_graph(vertices, src = edges$src, dst = edges$dst)

e <- edges(g)
e_test <- data.frame(
  src = c("b", "a", "a"),
  dst = c("a", "b", "c"),
  weights = c(1, 1, 1)
)
expect_equal(e, e_test)

e <- get_edgelist(g)
e_test <- data.frame(
  src = c(2, 3, 3),
  dst = c(3, 2, 1),
  weights = c(1, 1, 1)
)
expect_equal(e, e_test)

v <- vertices(g)
expect_equal(v, vertices)

free_graph(g)


# ==============================================================================

vertices <- c("c", "b", "a")
edges <- data.frame(
  src = character(0), 
  dst = character(0)
)

g <- create_graph(vertices, src = edges$src, dst = edges$dst)

e <- edges(g)
e_test <- data.frame(
  src = character(0), 
  dst = character(0), 
  weights = numeric(0)
)
expect_equal(e, e_test)

e <- get_edgelist(g)
e_test <- data.frame(
  src = integer(0),
  dst = integer(0),
  weights = numeric(0)
)
expect_equal(e, e_test)

v <- vertices(g)
expect_equal(v, vertices)

free_graph(g)
