#include "decompose_exposure.h"

std::vector<DoubleVec> decompose_exposure(const Graph& graph,
    const DoubleVec& values, const DoubleVec& exposure, 
    const DoubleVec& weights, double alpha) {
  if (!graph.has_layers()) 
    throw std::runtime_error("decompose_exposure is only callable for a graph with layers");
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
    for (degree_t j = 0; j < k; ++p_dst, ++p_weights, ++p_layers) {
      const layer_t layer = *p_layers;
      if (layer < 1 || layer > graph.nlayers) std::runtime_error("Invalid layer");
      vid_t w = *p_dst;
      result[layer-1L][v] += (1-alpha) * (*p_weights) * weights[w] * values[w];
      result[graph.nlayers + layer-1L][v] += alpha * (*p_weights) * weights[w] * exposure[w];
    }
  }
  return result;
}

