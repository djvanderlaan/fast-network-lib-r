#include "connected_components.h"

std::vector<vid_t> connected_components(const Graph& graph) {
  std::vector<vid_t> components(graph.nvertices);
  // Assign each vertex to it's own component
  for (vid_t i = 0; i < graph.nvertices; ++i) components[i] = i;

  bool components_changed = true;
  do {
    components_changed = false;
    auto pe1 = graph.edges.begin();
    for (vid_t i = 0; i < graph.nvertices; ++i) {
      const degree_t k = graph.degrees[i];
      vid_t comp_id = components[i];
      bool comp_changed = false;
      auto pe2 = pe1;
      for (degree_t j = 0; j < k; ++j, pe1++) {
        const vid_t dcomp_id = components[*pe1];
        if (comp_id != dcomp_id) {
          comp_changed = true;
          comp_id = std::min(comp_id, dcomp_id);
        }
      }
      if (comp_changed) {
        for (degree_t j = 0; j < k; ++j, pe2++) {
          components[*pe2] = comp_id;
        }
        components[i] = comp_id;
        components_changed = true;
      }
    }
  } while (components_changed);
  return components;
}
