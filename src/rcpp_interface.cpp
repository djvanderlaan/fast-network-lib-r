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
int create_graphw_rcpp(int nvertices, IntegerVector src, IntegerVector dst,
    NumericVector weights) {
  Graph* graph = new Graph(nvertices);
  int prev_src = 0;
  for (int i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    graph->add_edge(src[i], dst[i], weights[i], false);
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
  for (size_t i = 0; i < graphs.size(); ++i) {
    delete graphs[i];
    graphs[i] = 0;
  }
}

// [[Rcpp::export]]
IntegerVector stats_rcpp(int graphid) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) return 0;
  return IntegerVector::create(
    Named("nvertices") = graph->nvertices,
    Named("nedges") = graph->edges.size()
  );
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

// [[Rcpp::export]]
DataFrame get_edgelist_rcpp(int graphid) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  IntegerVector dst(graph->edges.size());
  IntegerVector src(graph->edges.size());
  NumericVector weights(graph->edges.size());

  auto p = graph->edges.cbegin();
  auto pw = graph->weights.cbegin();
  auto p_dst = dst.begin();
  auto p_weights = weights.begin();
  auto p_src = src.begin();
  for (vid_t i = 0; i < graph->nvertices; ++i) {
    const degree_t k = graph->degrees[i];
    for (degree_t j = 0; j < k; ++j, p++, p_dst++, p_src++, p_weights++) {
      (*p_dst) = *p;
      (*p_src) = i;
      (*p_weights) = *pw;
    }
  }
  return DataFrame::create(
    Named("src") = src + 1L,
    Named("dst") = dst + 1L,
    Named("weights") = weights
  );
}


