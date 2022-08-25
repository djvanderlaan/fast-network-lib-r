# Here we also test free_graph, free_all_graphs and graph_stats

source("helpers.R")

library(fastnetworklib)


g <- generate_poisson(10, 2.5, 0)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats$nvertices, 10)

g <- generate_poisson(0, 2.5, 0)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats$nvertices, 0)
expect_equal(stats$nedges, 0)

g <- generate_poisson(10, 0, 0)
stats <- graph_stats(g)
free_graph(g)
expect_equal(stats$nvertices, 10)
expect_equal(stats$nedges, 0)

expect_error(generate_poisson(NA, 2.5, 0))
expect_error(generate_poisson(-1, 2.5, 0))
expect_error(generate_poisson(.Machine$integer.max+1.0, 2.5, 0))
expect_error(generate_poisson(c(1,10), 2.5, 0))
expect_error(generate_poisson(10, -1, 0))
expect_error(generate_poisson(10, NA, 0))
expect_error(generate_poisson(10, c(1,2), 0))
expect_error(generate_poisson(10, 2.5, -1))
expect_error(generate_poisson(10, 2.5, NA))
expect_error(generate_poisson(10, 2.5, .Machine$integer.max+1.0))
expect_error(generate_poisson(10, 2.5, c(0, 2)))

