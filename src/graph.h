#ifndef graph_h
#define graph_h

#include <vector>
#include <stdexcept>

typedef unsigned int vid_t;
typedef unsigned int degree_t;
typedef float weight_t;


class Graph {
  public:
    Graph(vid_t nvertices = 0, size_t nedges = 0) : nvertices(nvertices), 
      degrees(nvertices), positions(nvertices), edges(nedges), weights(nedges) {
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

    void update_positions(vid_t from = 0) {
      if (nvertices == 0) return;
      vid_t pos = from == 0 ? 0 : positions[from-1] + degrees[from-1];
      for (size_t i = from; i < nvertices; ++i) {
        positions[i] = pos;
        pos += degrees[i];
      }
    }


  public:
    vid_t nvertices;
    std::vector<degree_t> degrees;
    std::vector<vid_t> positions;
    std::vector<vid_t> edges;
    std::vector<weight_t> weights;
    vid_t last_edge_src = 0;
};

#endif
