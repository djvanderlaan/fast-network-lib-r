#
#pkgload::load_all()
#
#nvert <- 10
#edges <- data.frame(
#    src = c(1,2,1,4,6,7,6),
#    dst = c(2,3,2,1,8,8,9)
#  )
#
#
#
#g <- create_graph(seq_len(nvert)-1L, edges$src, edges$dst)
#
#a <- connected_components(g)
#a
#
#free_graph(g)
#
#nvert <- 10
#edges <- data.frame(
#    src = integer(0),
#    dst = integer(0)
#  )
#
#
#b <- reclin2:::equivalence(seq_len(nvert)-1L, edges$src, edges$dst)
#
#t <- table(a, b)
## er mag in iedere rij en kolom maar 1 waarde != 0 zijn
#stopifnot(all(apply(t, 1, \(x) sum(x != 0)) == 1))
#stopifnot(all(apply(t, 2, \(x) sum(x != 0)) == 1))
#t
#



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

exp <- localised_random_walk(g, values = rep(c(0,1), length.out = 10), weights = rep(1.0, 10))
exp

get_edgelist(g)

d <- decompose_exposure_rcpp(g, values = rep(c(0,1), length.out = 10), exposure = exp, 
  weights = rep(1.0, 10), alpha = 0.85)

d

d[[1]] + d[[2]] + d[[3]] + d[[4]]
exp

edges

vert <- data.frame(id = 1:10, exp = exp, y = rep(c(0, 1), length.out = 10))
vert

library(data.table)
setDT(vert)

e <- get_edgelist(g)
setDT(e)

m <- merge(e, vert, by.x = "dst", by.y = "id", all.x = TRUE)
m


m2 <- m[, .(direct = sum((1-0.85)*weights*y), indirect = sum(0.85*weights*exp)), by = .(src)]
m3 <- merge(vert, m2, by.x = "id", by.y = "src", all.x = TRUE)
m3

d

m3[, direct_2 := d[[1]] + d[[2]]]
m3[, indirect_2 := d[[3]] + d[[4]]]

m3



# Another test with a larger network and less isolated edges
pkgload::load_all()
library(data.table)

n <- 1000
nedges <- n * 20
nlayers <- 2
vert <- data.table(id = seq_len(n), y = rbinom(n, 1, 0.1))
edges <- data.table(src = sample(n, nedges, replace = TRUE), 
  dst = sample(n, nedges, replace = TRUE), layer = sample(nlayers, nedges, replace = TRUE))
edges <- unique(edges[src != dst])

edges[, weight := 1/.N, by = .(src, layer)]
edges[, weight := weight/sum(weight), by = .(src)]
edges

setkey(edges, src, dst, layer)

g <- create_graph(vert$id, src = integer(0), dst = integer(0))
add_edgesl_rcpp(g, edges$src-1L, edges$dst-1L, edges$weight, NULL)

add_edgesl_rcpp(g, edges$src-1L, edges$dst-1L, edges$weight, edges$layer)

alpha <- 0.85
vert[, weight := runif(n, 0.2, 1.0)]
vert[, weight := weight/sum(weight)*.N]
exp <- localised_random_walk(g, vert$y, weights = vert$weight, alpha = alpha)
vert[, exposure := exp]

#d <- decompose_exposure_rcpp(g, values = vert$y, exposure = vert$exposure, 
  #weights = vert$weight, alpha = alpha)

decomp <- decompose_exposure(g, values = vert$y, exposure = vert$exposure, 
  weights = vert$weight, alpha = alpha)
setDT(decomp)
decomp

#decomp <- rbind(
  #data.table(id = vert$id, layer = 1, direct = d[[1]], indirect = d[[3]]),
  #data.table(id = vert$id, layer = 2, direct = d[[2]], indirect = d[[4]])
  #)
#decomp


m <- merge(edges, vert, by.x = "dst", by.y = "id", all.x = TRUE)
m <- m[, .(direct = sum((1-alpha)*weight.x*weight.y*y), 
  indirect = sum(alpha*weight.x*weight.y*exposure)), by = .(id = src, layer)]
m <- merge(vert[, .(id)], m, by = "id", all.x = TRUE)
m

nrow(m)
nrow(decomp)

test <- merge(decomp, m, by = c("id", "layer"), all = TRUE)

test

range(test$direct.x - test$direct.y)
range(test$indirect.x - test$indirect.y)

