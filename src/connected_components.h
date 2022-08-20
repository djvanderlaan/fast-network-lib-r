#ifndef connected_components_h
#define connected_components_h

#include "graph.h"
#include <vector>

// Calculate the fully connected components of the network
//
// ## Arguments
// graph: the graph for which to calculate the components.
//
// ## Result
// Returns a vector with nvertices elements with the numbers of the components
// each vertex belongs. Components are not numbered necessarily sequentially;
// there can be numbers missing. The numbers of the components can run from 0 to
// `nvertices-1`. 
//
std::vector<vid_t> connected_components(const Graph& graph);

#endif
