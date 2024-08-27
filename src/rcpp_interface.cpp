#include <Rcpp.h>

using namespace Rcpp;

#include "graph.h"
#include "connected_components.h"
#include "generate_poisson.h"
#include "localised_random_walk.h"
#include "normalise_weights.h"
#include "pajek.h"


// Store with graphs
std::vector<Graph*> graphs;

// [[Rcpp::export]]
int create_graph_rcpp(int nvertices, IntegerVector src, IntegerVector dst) {
  Graph* graph = new Graph(nvertices, src.size());
  int prev_src = 0;
  for (R_xlen_t i = 0; i < src.size(); ++i) {
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
  for (R_xlen_t i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    graph->add_edge(src[i], dst[i], weights[i], false);
    prev_src = src[i];
  }
  graph->update_positions();
  graphs.push_back(graph);
  return graphs.size() - 1L;
}

// [[Rcpp::export]]
int add_edges_rcpp(int graphid, IntegerVector src, IntegerVector dst) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  // Determine the src id of last edge
  int prev_src = 0;
  for (unsigned int i = 0; i < graph->nvertices; ++i) {
    const unsigned int k = graph->degrees[i];
    if (k > 0) prev_src = i;
  }
  // Add edges
  for (R_xlen_t i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    graph->add_edge(src[i], dst[i], 1.0, false);
    prev_src = src[i];
  }
  graph->update_positions();
  return graphid;
}

// [[Rcpp::export]]
int add_edgesw_rcpp(int graphid, IntegerVector src, IntegerVector dst, 
    NumericVector weights) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  // Determine the src id of last edge
  int prev_src = 0;
  for (unsigned int i = 0; i < graph->nvertices; ++i) {
    const unsigned int k = graph->degrees[i];
    if (k > 0) prev_src = i;
  }
  // Add edges
  for (R_xlen_t i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    graph->add_edge(src[i], dst[i], weights[i], false);
    prev_src = src[i];
  }
  graph->update_positions();
  return graphid;
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
NumericVector stats_rcpp(int graphid) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) return 0;
  return NumericVector::create(
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
  for (size_t i = 0; i < comp.size(); ++i)
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
    for (degree_t j = 0; j < k; ++j, p++, pw++, p_dst++, p_src++, p_weights++) {
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

// [[Rcpp::export]]
int generate_poisson_rcpp(int nvertices, double mean_degree, int seed) {
  Graph* graph = new Graph(generate_poisson(nvertices, mean_degree, seed));
  graphs.push_back(graph);
  return graphs.size() - 1L;
}

// [[Rcpp::export]]
NumericVector localised_random_walk_rcpp(int graphid, std::vector<double> values, 
    std::vector<double> weights, double alpha, int nstep_max, double precision, 
    int nthreads, bool normalise) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  if (normalise) normalise_weights(*graph);
  unsigned int nstep = 0;
  std::vector<double> res = localised_random_walk(*graph, values, weights, alpha, nstep_max, precision, 
      nthreads, &nstep);
  NumericVector rres = wrap(res);
  rres.attr("nstep") = nstep;
  return rres;
}

// [[Rcpp::export]]
void write_pajek_rcpp(int graphid, const std::string& filename) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  write_pajek(*graph, filename);
}

// [[Rcpp::export]]
int read_pajek_rcpp(const std::string& filename) {
  Graph* graph = new Graph{read_pajek(filename)};
  graphs.push_back(graph);
  return graphs.size() - 1L;
}


