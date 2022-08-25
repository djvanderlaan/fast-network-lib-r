#ifndef localised_random_walk_h
#define localised_random_walk_h

#include "graph.h"
#include <vector>

// Compute localised random walk
//
// Arguments
// - graph: a Graph object; it is expected that the weights are normalised to 1
//   (the weights of the outgoing edges for each vertex should sum to 1).
// - values: a vector with values for each node. Should have the same length as
//   the number of vertices in the graph. 
// - weights: vector with weights for each node. Should have the same length as
//   the number of vertices in the graph.
// - alpha: probability of continuing the random walk. Should be >=0 and <1. Can
//   also be a vector, in which case each vertex can have a different
//   probability. When the number of vertices in the graph is larger than the
//   number of elements in `alphas` the elements in `alphas` are recycled. 
// - nstep_max: maximumber of iterations to perform. 
// - precision: when all of the scores change less than precision the iteration
//   is stopped.
// - nthreads: number of threads to use for the computation. Values of 0 or 1
//   mean that the computation is performed in the main thread. 
// - nstep: when not a nullptr the number of iteration steps is assigned to the
//   variable pointed to. 
//
std::vector<double> localised_random_walk(const Graph& graph, 
    const std::vector<double>& values, const std::vector<double>& weights, 
    double alpha = 0.85, unsigned int nstep_max = 1000, double precision = 1E-5, 
    unsigned int nthreads = 0, unsigned int* nstep = nullptr);

std::vector<double> localised_random_walk(const Graph& graph, 
    const std::vector<double>& values, const std::vector<double>& weights, 
    const std::vector<double>& alphas, unsigned int nstep_max = 1000, double precision = 1E-5, 
    unsigned int nthreads = 0, unsigned int* nstep = nullptr);

#endif
