source("helpers.R")

library(fastnetworklib)

nvert <- 10
values <- runif(nvert, 0, 1)
weights <- rep(1, nvert)
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
res <- localised_random_walk(g, values, weights, alpha = 0.85, nstep_max = 200, 
    precision = 1E-5, nthreads = 0) 
free_graph(g)
expect_equal(length(res), 10)
expect_equal(res[c(1,4,6,9,10)], c(NaN, NaN, NaN, NaN, NaN))

nvert <- 10
values <- runif(nvert, 0, 1)
weights <- rep(1, nvert)
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
res <- localised_random_walk(g, values, weights, alpha = 0.85, nstep_max = 200, 
    precision = 1E-5, nthreads = 0) 
free_graph(g)
expect_equal(length(res), 10)
expect_equal(as.numeric(res), rep(NaN, 10))


nvert <- 0
values <- runif(nvert, 0, 1)
weights <- rep(1, nvert)
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )
g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
res <- localised_random_walk(g, values, weights, alpha = 0.85, nstep_max = 200, 
    precision = 1E-5, nthreads = 0) 
free_graph(g)
expect_equal(length(res), 0)
