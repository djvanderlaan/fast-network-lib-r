
source("helpers.R")

library(fastnetworklib)

# =============================================================================
# No weights

v <- 1:10
e <- data.frame(src = rep(1:10, each = 2), dst = sample(v, 20, replace = TRUE))


g  <- create_graph(v, src = e$src[1:10], dst = e$dst[1:10])

add_edges(g, v, src = e$src[11:20], dst = e$dst[11:20])

stats <- graph_stats(g)

expect_equal(stats$nvertices, 10)
expect_equal(stats$nedges, 20)

e_tst <- get_edgelist(g)
expect_equal(e_tst$src, e$src)
expect_equal(e_tst$dst, e$dst)
expect_equal(e_tst$weights, rep(1, 20))

expect_error( add_edges(g, v, src = e$src[11:20], dst = e$dst[11:20]))

# Adding no edges should to nothing
add_edges(g, v, src = integer(0), dst = integer(0))
e_tst <- get_edgelist(g)
expect_equal(e_tst$src, e$src)
expect_equal(e_tst$dst, e$dst)
expect_equal(e_tst$weights, rep(1, 20))

# Add invalid edges
expect_error(add_edges(g, v, src = 100, dst = 100))


# =============================================================================
# Weights

v <- 1:10
e <- data.frame(src = rep(1:10, each = 2), dst = sample(v, 20, replace = TRUE),
  w = runif(20))


g  <- create_graph(v, src = e$src[1:10], dst = e$dst[1:10], weights = e$w[1:10])

add_edges(g, v, src = e$src[11:20], dst = e$dst[11:20], weights = e$w[11:20])

stats <- graph_stats(g)

expect_equal(stats$nvertices, 10)
expect_equal(stats$nedges, 20)

e_tst <- get_edgelist(g)
expect_equal(e_tst$src, e$src)
expect_equal(e_tst$dst, e$dst)
# Weights are stored as float so we expect small differences
stopifnot(isTRUE(all.equal(e_tst$weights, e$w, tolerance = 1E-6)))

expect_error( add_edges(g, v, src = e$src[11:20], dst = e$dst[11:20],
    weights = e$w[11:20]))

# Adding no edges should to nothing
add_edges(g, v, src = integer(0), dst = integer(0), weights = numeric(0))
e_tst <- get_edgelist(g)
expect_equal(e_tst$src, e$src)
expect_equal(e_tst$dst, e$dst)
stopifnot(isTRUE(all.equal(e_tst$weights, e$w, tolerance = 1E-6)))

# Add invalid edges
expect_error(add_edges(g, v, src = 100, dst = 100, weights = 10))



add_edges(g, v, src = 10, dst = 10, weights = NULL)
