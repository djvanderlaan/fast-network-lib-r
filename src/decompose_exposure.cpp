#include "decompose_exposure.h"
#include <cmath>

// Version of decompose_exposure for graph without layers. decompose_graph will
// call this one when the graph had no layers
std::vector<DoubleVec> decompose_exposure_no_layers(const Graph& graph,
    const DoubleVec& values, const DoubleVec& exposure, 
    const DoubleVec& weights, double alpha) {
  // Initialise result
  std::vector<DoubleVec> result(2L);
  result[0L] = DoubleVec(graph.nvertices, 0.0);
  result[1L] = DoubleVec(graph.nvertices, 0.0);
  // Initialise iterators over edges
  auto p_dst     = graph.edges.cbegin();
  auto p_weights = graph.weights.cbegin();
  // Go over the the network
  for (vid_t v = 0; v < graph.nvertices; ++v) {
    const degree_t k = graph.degrees[v];
    for (degree_t j = 0; j < k; ++j, ++p_dst, ++p_weights) {
      vid_t w = *p_dst;
      result[0L][v] += (1-alpha) * (*p_weights) * weights[w] * values[w];
      const double exposure_w = exposure[w];
      if (!std::isnan(exposure_w)) 
        result[1L][v] += alpha * (*p_weights) * exposure_w;
    }
  }
  // normalise the result; the sum of the direct and indirect effects should add
  // up to the total exposure. Because of dead-ends in the network this is not
  // alway the case. Scale the results to make them match
  for (vid_t v = 0; v < graph.nvertices; ++v) {
    const double total = result[0][v] + result[1][v];
    const double factor = (std::isnan(total) || total <= 0.0) ? 1.0 : 
      exposure[v]/total;
    result[0][v] = result[0][v]*factor;
    result[1][v] = result[1][v]*factor;
  }
  return result;
}


std::vector<DoubleVec> decompose_exposure(const Graph& graph,
    const DoubleVec& values, const DoubleVec& exposure, 
    const DoubleVec& weights, double alpha) {
  if (!graph.has_layers()) 
    return decompose_exposure_no_layers(graph, values, exposure, weights, alpha);
  // Initialise result
  std::vector<DoubleVec> result(graph.nlayers*2L);
  for (layer_t i = 0; i < result.size(); ++i) {
    result[i] = DoubleVec(graph.nvertices, 0.0);
  }
  // Initialise iterators over edges
  auto p_dst     = graph.edges.cbegin();
  auto p_weights = graph.weights.cbegin();
  auto p_layers  = graph.layers.cbegin();
  // Go over the the network
  for (vid_t v = 0; v < graph.nvertices; ++v) {
    const degree_t k = graph.degrees[v];
    for (degree_t j = 0; j < k; ++j, ++p_dst, ++p_weights, ++p_layers) {
      const layer_t layer = *p_layers;
      if (layer < 1 || layer > graph.nlayers) std::runtime_error("Invalid layer");
      vid_t w = *p_dst;
      result[layer-1L][v] += (1-alpha) * (*p_weights) * weights[w] * values[w];
      const double exposure_w = exposure[w];
      if (!std::isnan(exposure_w)) 
        result[graph.nlayers + layer-1L][v] += alpha * (*p_weights) * exposure_w;
    }
  }
  // normalise the result; the sum of the direct and indirect effects should add
  // up to the total exposure. Because of dead-ends in the network this is not
  // alway the case. Scale the results to make them match
  for (vid_t v = 0; v < graph.nvertices; ++v) {
    double total = 0.0;
    for (layer_t l = 0, lend = graph.nlayers*2; l < lend; ++l) 
      total += result[l][v];
    const double factor = (std::isnan(total) || total <= 0.0) ? 1.0 : 
      exposure[v]/total;
    for (layer_t l = 0, lend = graph.nlayers*2; l < lend; ++l) 
      result[l][v] = result[l][v]*factor;
    
  }
  return result;
}

