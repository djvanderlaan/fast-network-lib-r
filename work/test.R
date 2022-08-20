
pkgload::load_all()

nvert <- 10
edges <- data.frame(
    src = c(1,2,1,4,6,7,6),
    dst = c(2,3,2,1,8,8,9)
  )



g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)

a <- connected_components(g)

free_graph(g)


b <- reclin2:::equivalence(seq_len(nvert)-1L, edges$src, edges$dst)

t <- table(a, b)
# er mag in iedere rij en kolom maar 1 waarde != 0 zijn
stopifnot(all(apply(t, 1, \(x) sum(x != 0)) == 1))
stopifnot(all(apply(t, 2, \(x) sum(x != 0)) == 1))
t



