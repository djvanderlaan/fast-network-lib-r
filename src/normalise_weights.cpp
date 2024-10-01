#include "normalise_weights.h"

void normalise_weights(Graph& graph) {
  auto cpw = graph.weights.cbegin();
  auto pw = graph.weights.begin();
  for (unsigned int i = 0; i < graph.nvertices; ++i) {
    unsigned int k = graph.degrees[i];
    float sum = 0.0;
    for (unsigned int j = 0; j < k; ++j, ++cpw) sum += *cpw;
    float scale = 1.0/sum;
    for (unsigned int j = 0; j < k; ++j, ++pw) *pw = *pw * scale;
  }
}

void normalise_weights_by_layer(Graph& graph) {
  if (!graph.has_layers()) return normalise_weights(graph);
  auto cpw = graph.weights.cbegin();
  auto pw = graph.weights.begin();
  auto cplayer = graph.layers.cbegin();
  auto player = graph.layers.cbegin();
  std::vector<weight_t> sum(graph.nlayers+1L, 0.0);
  for (unsigned int i = 0; i < graph.nvertices; ++i) {
    unsigned int k = graph.degrees[i];
    std::fill(sum.begin(), sum.end(), 0.0);
    float totsum = 0.0;
    for (unsigned int j = 0; j < k; ++j, ++cpw, ++cplayer) {
      sum[*cplayer] += *cpw;
      totsum += *cpw;
    }
    for (size_t j = 0; j < sum.size(); ++j) sum[j] /= totsum;
    for (unsigned int j = 0; j < k; ++j, ++pw, ++player) 
      *pw = *pw * sum[*cplayer];
  }
}

