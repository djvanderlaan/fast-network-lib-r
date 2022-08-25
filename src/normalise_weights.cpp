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

