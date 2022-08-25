#ifndef generate_poisson_h
#define generate_poisson_h

#include "graph.h"

// Generate a random poisson network where each node has a given expected degree
//
// Arguments
// - nvertices number of vertices of the resulting network
// - mean_degree expected out degree of each vertex
// - seed seed for the random number generator. 
//
// Details
// Each vertex has an expected out degree of `mean_degree`. The actual outdegree
// follows a Poisson distribution. The vertices the vertex is connected to are
// randomly drawn from the total set of vertices. This also means there is a 
// (small) probability of self loops. 
//
Graph generate_poisson(vid_t nvertices, double mean_degree, 
  unsigned int seed = 0);


#endif
