#ifndef graph_h
#define graph_h

#include <vector>
#include <stdexcept>
#include <cstdint>

typedef unsigned int vid_t;
typedef unsigned int degree_t;
typedef float weight_t;
typedef uint8_t layer_t;


class Graph {
  public:
    Graph(vid_t nvertices = 0, size_t nedges = 0) : nvertices(nvertices), 
        degrees(nvertices), positions(nvertices), edges{}, weights{}, layers{} {
      if (nedges > 0) {
        edges.reserve(nedges);
        weights.reserve(nedges);
        // we don't reserve for layer because not all networks will have
        // use layers
      }
    };

    void add_vertex(vid_t id, bool update_pos = true) {
      if (id >= nvertices) {
        const vid_t p0 = nvertices;
        nvertices = id+1;
        degrees.resize(nvertices);
        positions.resize(nvertices);
        if (update_pos) update_positions(p0);
      }
    }

    // When adding a large number of edges it is faster to set update_pos to 
    // false and manually call update_positions when finished with adding
    // edges.
    void add_edge(vid_t src, vid_t dst, weight_t weight = 1.0, 
        bool update_pos = true) {
      add_vertex(std::max(src, dst), false);
      if (src >= last_edge_src) {
        degrees[src] = degrees[src] + 1;
        edges.push_back(dst);
        weights.push_back(weight);
        if (update_pos) update_positions(last_edge_src);
        last_edge_src = src;
      } else {
        const vid_t index = positions[src+1];
        auto p = edges.begin() + index;
        edges.insert(p, dst);
        auto pw = weights.begin() + index;
        weights.insert(pw, weight);
        degrees[src] = degrees[src] + 1;
        if (update_pos) update_positions(src);
      }
    }

    void add_edge_to_layer(vid_t src, vid_t dst, layer_t layer, 
        weight_t weight = 1.0, bool update_pos = true) {
      has_layers(); // will throw if something wrong with layers
      add_vertex(std::max(src, dst), false);
      if (src >= last_edge_src) {
        degrees[src] = degrees[src] + 1;
        edges.push_back(dst);
        weights.push_back(weight);
        layers.push_back(layer);
        if (update_pos) update_positions(last_edge_src);
        last_edge_src = src;
      } else {
        const vid_t index = positions[src+1];
        auto p = edges.begin() + index;
        edges.insert(p, dst);
        auto pw = weights.begin() + index;
        weights.insert(pw, weight);
        auto pl = layers.begin() + index;
        layers.insert(pl, layer);
        degrees[src] = degrees[src] + 1;
        if (update_pos) update_positions(src);
      }
      if (layer > nlayers) nlayers = layer;
    }

    void update_positions(vid_t from = 0) {
      if (nvertices == 0) return;
      vid_t pos = from == 0 ? 0 : positions[from-1] + degrees[from-1];
      for (size_t i = from; i < nvertices; ++i) {
        positions[i] = pos;
        pos += degrees[i];
      }
    }

    bool has_layers() const {
      if (nlayers > 0 || layers.size() > 0) {
        if (layers.size() != edges.size())
          throw std::runtime_error("Size of layers != number of edges.");
      }
      return nlayers > 0;
    }

  public:
    vid_t nvertices;
    std::vector<degree_t> degrees;
    std::vector<vid_t> positions;
    std::vector<vid_t> edges;
    std::vector<weight_t> weights;
    std::vector<layer_t> layers;
    layer_t nlayers = 0;
    vid_t last_edge_src = 0;


};

#endif
