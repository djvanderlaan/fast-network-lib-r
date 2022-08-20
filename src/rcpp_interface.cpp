#include <Rcpp.h>

using namespace Rcpp;

#include "graph.h"
#include "connected_components.h"

// Store with graphs
std::vector<Graph*> graphs;

// [[Rcpp::export]]
int create_graph_rcpp(int nvertices, IntegerVector src, IntegerVector dst) {
  Graph* graph = new Graph(nvertices);
  int prev_src = 0;
  for (int i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    graph->add_edge(src[i], dst[i], 1.0, false);
    prev_src = src[i];
  }
  graph->update_positions();
  graphs.push_back(graph);
  return graphs.size() - 1L;
}

// [[Rcpp::export]]
void free_graph_rcpp(int graphid) {
  Graph* graph = graphs.at(graphid);
  if (graph != 0) delete graph;
  graphs[graphid] = 0;
}

// [[Rcpp::export]]
void free_all_graphs_rcpp() {
  for (Graph* g: graphs) {
    delete g;
    g = 0;
  }
}

// [[Rcpp::export]]
IntegerVector connected_components_rcpp(int graphid) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  std::vector<vid_t> comp = connected_components(*graph);
  IntegerVector res(comp.size());
  for (unsigned int i = 0; i < comp.size(); ++i)
    res[i] = comp[i];
  return res;
}

