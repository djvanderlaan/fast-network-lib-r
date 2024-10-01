
pkgload::load_all()

nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )



g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)

a <- connected_components(g)
a

free_graph(g)

nvert <- 10
edges <- data.frame(
    src = integer(0),
    dst = integer(0)
  )


b <- reclin2:::equivalence(seq_len(nvert)-1L, edges$src, edges$dst)

t <- table(a, b)
# er mag in iedere rij en kolom maar 1 waarde != 0 zijn
stopifnot(all(apply(t, 1, \(x) sum(x != 0)) == 1))
stopifnot(all(apply(t, 2, \(x) sum(x != 0)) == 1))
t




pkgload::load_all()

nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,6,6),
    dst = c(2,3,2,1,8,4,9)
  )


edges$layer <- c(1,1,2,2,1,1,2)
o <- order(edges$src)
edges <- edges[o, ]
edges$weight <- 2.0


g <- create_graph(seq_len(nvert)-1L, src = integer(0), dst = integer(0))
g

#add_edgesl_rcpp(g, edges$src-1L, edges$dst-1L, NULL, edges$layer)

add_edgesl_rcpp(g, edges$src-1L, edges$dst-1L, edges$weight, edges$layer)

get_edgelist(g)

localised_random_walk(g, values = rep(c(0,1), length.out = 10), weights = rep(1.0, 10))

get_edgelist(g)





