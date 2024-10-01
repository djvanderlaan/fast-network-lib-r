#ifndef normalise_weights_h
#define normalise_weights_h

#include "graph.h"

// Make sure the the weights of the outgoing edges of a vertex add up to one
//
// ## Arguments
// graph: the graph for which to normalise the weighs
//
// ## Result
// The function is called for its side effect of modifying the weights of the
// supplied graph object. If $S_i$ is the sum of the weights of vertex $i$ and
// $w_ij$ the weight of edge, then the normalised weighs are $w'_ij = w_ij/S_i$. 
//
// The function `normalise_weights_by_layer` will ensure that each of the layers
// has the same total weight and the total weights for one vertex will be equal
// to one. 
//
void normalise_weights(Graph& graph);
void normalise_weights_by_layer(Graph& graph);

#endif
