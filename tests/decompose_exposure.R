
source("helpers.R")
library(fastnetworklib)




# ==============================================================================
# Random network; fully connected

# Generate a graph
set.seed(10)
n <- 1000
nedges <- n * 10
nlayers <- 2
vert <- data.frame(id = seq_len(n), y = rbinom(n, 1, 0.1))
edges <- data.frame(src = sample(n, nedges, replace = TRUE), 
  dst = sample(n, nedges, replace = TRUE), 
  layer = sample(nlayers, nedges, replace = TRUE))
edges <- edges[edges$src != edges$dst, ]
edges <- unique(edges)
# Calculate edge weights
n <- aggregate(data.frame(weight = rep(1, nrow(edges))), 
  edges[, c("src", "layer")], sum)
n$weight <- 1/n$weight
edges <- merge(edges, n)
n <- aggregate(edges[, "weight", drop = FALSE], 
  edges[, "src", drop = FALSE], sum)
names(n)[2] <- "totweight"
edges <- merge(edges, n) 
edges$weight <- edges$weight / edges$totweight
edges$totweight <- NULL
edges <- edges[order(edges$src, edges$dst), ]

# Create graph object from this
g <- create_graph(vert$id, src = integer(0), dst = integer(0))
add_edges(g, vertex_ids = vert$id, src = edges$src, 
  dst = edges$dst, weights = edges$weight, layer = edges$layer)

# Calculate exposure
alpha <- 0.85
vert$weight <- runif(n, 0.2, 1.0)
vert$weight <- vert$weight / sum(vert$weight) * nrow(vert)
#vert[, weight := 1]
exp <- localised_random_walk(g, vert$y, 
  weights = vert$weight, alpha = alpha, precision=1E-10)
vert$exposure <- exp

# Decompose exposure
decomp <- decompose_exposure(g, values = vert$y, exposure = vert$exposure, 
  weights = vert$weight, alpha = alpha)

# Now also calculate decomposition manually
m <- merge(edges, vert, by.x = "dst", by.y = "id", all.x = TRUE)
m$direct <- (1-alpha)*m$weight.x*m$weight.y*m$y
m$indirect <- alpha*m$weight.x*m$weight.y*m$exposure
m <- aggregate(m[, c("direct", "indirect")], m[, c("src", "layer")], sum, na.rm = TRUE)
names(m)[1] <- "id" 
m <- merge(expand.grid(id = vert$id, layer = 1:2), m, 
  by = c("id", "layer"), all.x = TRUE)
m$direct[is.na(m$direct)] <- 0
m$indirect[is.na(m$indirect)] <- 0
# Normalise
tmp <- aggregate(m[, c("direct", "indirect")], m[, c("id"), drop = FALSE], sum)
tmp$tot <- tmp$direct + tmp$indirect
tmp$exp <- vert$exposure[match(tmp$id, vert$id)]
tmp$fac <- tmp$exp/tmp$tot
tmp$fac[is.na(tmp$fac)] <- 1
mtch <- match(m$id, tmp$id)
m$direct <- m$direct*tmp$fac[mtch]
m$indirect <- m$indirect*tmp$fac[mtch]

# Check if this matches result from decompose_exposure
test<- merge(decomp, m, by = c("id", "layer"), all = TRUE)
stopifnot(isTRUE(all.equal(test$direct.x, test$direct.y, tolerance=1E-5)))
stopifnot(isTRUE(all.equal(test$indirect.x, test$indirect.y, tolerance=1E-5)))

# Check if sum of all effects adds up to total exposure
test <- aggregate(decomp[, c("direct", "indirect")], 
  decomp[, c("id"), drop = FALSE], sum)
test$total <- test$direct + test$indirect
test$exposure <- vert$exposure[match(test$id, vert$id)]
test$exposure[is.na(test$exposure)] <- 0
stopifnot(isTRUE(all.equal(test$total, test$exposure, tolerance=1E-5)))

free_graph(g)


# ==============================================================================
# Random network; not fully connected

# Generate a graph
set.seed(10)
n <- 1000
nedges <- n * 1  # DIFFERENT FROM PREVIOUS TEST
nlayers <- 2
vert <- data.frame(id = seq_len(n), y = rbinom(n, 1, 0.1))
edges <- data.frame(src = sample(n, nedges, replace = TRUE), 
  dst = sample(n, nedges, replace = TRUE), 
  layer = sample(nlayers, nedges, replace = TRUE))
edges <- edges[edges$src != edges$dst, ]
edges <- unique(edges)
# Calculate edge weights
n <- aggregate(data.frame(weight = rep(1, nrow(edges))), 
  edges[, c("src", "layer")], sum)
n$weight <- 1/n$weight
edges <- merge(edges, n)
n <- aggregate(edges[, "weight", drop = FALSE], 
  edges[, "src", drop = FALSE], sum)
names(n)[2] <- "totweight"
edges <- merge(edges, n) 
edges$weight <- edges$weight / edges$totweight
edges$totweight <- NULL
edges <- edges[order(edges$src, edges$dst), ]

# Create graph object from this
g <- create_graph(vert$id, src = integer(0), dst = integer(0))
add_edges(g, vertex_ids = vert$id, src = edges$src, 
  dst = edges$dst, weights = edges$weight, layer = edges$layer)

# Calculate exposure
alpha <- 0.5  # DIFFERENT FROM PREVIOUS TEST
vert$weight <- runif(n, 0.2, 1.0)
vert$weight <- vert$weight / sum(vert$weight) * nrow(vert)
#vert[, weight := 1]
exp <- localised_random_walk(g, vert$y, 
  weights = vert$weight, alpha = alpha, precision=1E-10)
vert$exposure <- exp

# Decompose exposure
decomp <- decompose_exposure(g, values = vert$y, exposure = vert$exposure, 
  weights = vert$weight, alpha = alpha)

# Now also calculate decomposition manually
m <- merge(edges, vert, by.x = "dst", by.y = "id", all.x = TRUE)
m$direct <- (1-alpha)*m$weight.x*m$weight.y*m$y
m$indirect <- alpha*m$weight.x*m$weight.y*m$exposure
m <- aggregate(m[, c("direct", "indirect")], m[, c("src", "layer")], sum, na.rm = TRUE)
names(m)[1] <- "id" 
m <- merge(expand.grid(id = vert$id, layer = 1:2), m, 
  by = c("id", "layer"), all.x = TRUE)
m$direct[is.na(m$direct)] <- 0
m$indirect[is.na(m$indirect)] <- 0
# Normalise
tmp <- aggregate(m[, c("direct", "indirect")], m[, c("id"), drop = FALSE], sum)
tmp$tot <- tmp$direct + tmp$indirect
tmp$exp <- vert$exposure[match(tmp$id, vert$id)]
tmp$fac <- tmp$exp/tmp$tot
tmp$fac[is.na(tmp$fac)] <- 1
mtch <- match(m$id, tmp$id)
m$direct <- m$direct*tmp$fac[mtch]
m$indirect <- m$indirect*tmp$fac[mtch]

# Check if this matches result from decompose_exposure
test<- merge(decomp, m, by = c("id", "layer"), all = TRUE)
stopifnot(isTRUE(all.equal(test$direct.x, test$direct.y, tolerance=1E-5)))
stopifnot(isTRUE(all.equal(test$indirect.x, test$indirect.y, tolerance=1E-5)))

# Check if sum of all effects adds up to total exposure
test <- aggregate(decomp[, c("direct", "indirect")], 
  decomp[, c("id"), drop = FALSE], sum)
test$total <- test$direct + test$indirect
test$exposure <- vert$exposure[match(test$id, vert$id)]
test$exposure[is.na(test$exposure)] <- 0
stopifnot(isTRUE(all.equal(test$total, test$exposure, tolerance=1E-5)))

free_graph(g)

# ==============================================================================
# Simple network we can manually check
#
# (1 y=0) -[layer=1]-> (2 y=1)
#         \[layer=2]-> (3 y=0)

edges <- data.frame(
  src = c(1, 1),
  dst = c(2, 3),
  weight = c(0.5, 0.5),
  layer = c(1, 2)
  )

vertices <- data.frame(
    id = c(1,2,3),
    y = c(0, 1, 0),
    weight = 1.0
  )


g <- create_graph(vertices$id, src = integer(0), dst = integer(0))
add_edges(g, vertex_ids = vertices$id, src = edges$src, 
  dst = edges$dst, weights = edges$weight, layer = edges$layer)

alpha <- 0.6
exp <- localised_random_walk(g, vertices$y, weights = vertices$weight,
  alpha = alpha, precision=1E-10)
expect_equal(exp, c(0.5, NaN, NaN), attributes = FALSE)

decomp <- decompose_exposure(g, values = vertices$y, exposure = exp, 
  weights = vertices$weight, alpha = alpha)
decomp <- decomp[order(decomp$id, decomp$layer), ]

target <- data.frame(
  id = c(1,1,2,2,3,3),
  layer = c(1,2,1,2,1,2),
  direct = c(0.5, 0, 0, 0, 0, 0),
  indirect = 0
)
expect_equal(decomp, target, attributes = FALSE)

free_graph(g)


# ==============================================================================
# Simple network we can manually check
#
# (1 y=0) -[layer=1]-> (2 y=1) -[layer=1]-> (4 y=1)
#                              \[layer=1]-> (5 y=0)
#         \[layer=2]-> (3 y=0)

edges <- data.frame(
  src = c(1, 1, 2, 2),
  dst = c(2, 3, 4, 5),
  weight = c(0.5, 0.5, 0.5, 0.5),
  layer = c(1, 2, 1, 1)
  )

vertices <- data.frame(
    id = c(1,2,3, 4, 5),
    y = c(0, 1, 0, 1, 0),
    weight = 1.0
  )

g <- create_graph(vertices$id, src = integer(0), dst = integer(0))
add_edges(g, vertex_ids = vertices$id, src = edges$src, 
  dst = edges$dst, weights = edges$weight, layer = edges$layer)


alpha <- 0.6
exp <- localised_random_walk(g, vertices$y, weights = vertices$weight,
  alpha = alpha, precision=1E-10)
expect_equal(exp, c(0.5, 0.5, NaN, NaN, NaN), attributes = FALSE)

decomp <- decompose_exposure(g, values = vertices$y, exposure = exp, 
  weights = vertices$weight, alpha = alpha)
decomp <- decomp[order(decomp$id, decomp$layer), ]

target <- data.frame(
  id = c(1,1,2,2,3,3,4,4,5,5),
  layer = c(1,2,1,2,1,2,1,2,1,2),
  direct = c(0.285714285714286, 0, 0.5, 0, 0, 0, 0, 0, 0, 0),
  indirect = c(0.214285714285714, 0, 0, 0, 0, 0, 0, 0, 0, 0)
)
expect_equal(decomp, target, attributes = FALSE)

free_graph(g)
