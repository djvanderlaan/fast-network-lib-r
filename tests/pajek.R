source("helpers.R")

library(fastnetworklib)

g <- generate_poisson(10, 2.5, 0)
fn <- tempfile()
write_pajek(g, fn)
g2 <- read_pajek(fn)
invisible(file.remove(fn))
expect_equal(get_edgelist(g), get_edgelist(g2))
free_graph(g)
free_graph(g2)


g <- generate_poisson(0, 2.5, 0)
fn <- tempfile()
write_pajek(g, fn)
g2 <- read_pajek(fn)
invisible(file.remove(fn))
expect_equal(get_edgelist(g), get_edgelist(g2))
free_graph(g)
free_graph(g2)

