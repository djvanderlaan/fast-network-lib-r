source("helpers.R")

library(fastnetworklib)

nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
el <- get_edgelist(g)
free_graph(g)
expected <- data.frame(src = edges$src+1L, dst = edges$dst+1L, weights = 1.0)
# Make sure the order of both is the same, because that is not garanteed
expected <- expected[order(expected$src, expected$dst),]
rownames(expected) <- NULL
el <- el[order(el$src, el$dst),]
rownames(el) <- NULL
expect_equal(el, expected)

# No edges -> every vertex in its own component
nvert <- 10
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
el <- get_edgelist(g)
free_graph(g)
expected <- data.frame(src = edges$src, dst = edges$dst, weights = numeric(0))
# Make sure the order of both is the same, because that is not garanteed
expected <- expected[order(expected$src, expected$dst),]
rownames(expected) <- NULL
el <- el[order(el$src, el$dst),]
rownames(el) <- NULL
expect_equal(el, expected)

# Empty graph
nvert <- 0
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
el <- get_edgelist(g)
free_graph(g)
expected <- data.frame(src = edges$src, dst = edges$dst, weights = numeric(0))
# Make sure the order of both is the same, because that is not garanteed
expected <- expected[order(expected$src, expected$dst),]
rownames(expected) <- NULL
el <- el[order(el$src, el$dst),]
rownames(el) <- NULL
expect_equal(el, expected)


