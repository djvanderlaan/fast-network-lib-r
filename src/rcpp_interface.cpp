#include <Rcpp.h>

using namespace Rcpp;

#include "graph.h"
#include "connected_components.h"
#include "generate_poisson.h"
#include "localised_random_walk.h"
#include "normalise_weights.h"
#include "pajek.h"
#include "decompose_exposure.h"


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
int add_edgesl_rcpp(int graphid, IntegerVector src, IntegerVector dst, 
    Nullable<NumericVector> n_weights, Nullable<IntegerVector> n_layer) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  // Determine the src id of last edge
  int prev_src = 0;
  for (unsigned int i = 0; i < graph->nvertices; ++i) {
    const unsigned int k = graph->degrees[i];
    if (k > 0) prev_src = i;
  }
  // Check if we have layers and/or weights
  const bool has_weights = n_weights.isNotNull();
  const bool has_layers  = n_layer.isNotNull();
  const NumericVector weights = has_weights ? NumericVector{n_weights} : NumericVector{0UL};
  const IntegerVector layer   = has_layers  ? IntegerVector{n_layer}   : IntegerVector{0UL};
  // In case of a large number of insertiones better to first allocate memory
  const size_t new_size = graph->edges.size() + src.size();
  graph->edges.reserve(new_size);
  graph->weights.reserve(new_size);
  if (has_layers) graph->layers.reserve(new_size);
  // Add edges
  for (R_xlen_t i = 0; i < src.size(); ++i) {
    if (src[i] < prev_src) throw Rcpp::exception("Edges are out of order");
    const float weight = has_weights ? weights[i] : 1.0;
    if (!has_layers) {
      graph->add_edge(src[i], dst[i], weight, false);
    } else {
      const int l = layer[i];
      if (l < 1 || l > 255) throw Rcpp::exception("Layer < 1 or > 255 is not allowed.");
      graph->add_edge_to_layer(src[i], dst[i], l, weight, false);
    }
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
  if (graph->has_layers()) {
    IntegerVector dst(graph->edges.size());
    IntegerVector src(graph->edges.size());
    NumericVector weights(graph->edges.size());
    IntegerVector layers(graph->edges.size());

    auto p = graph->edges.cbegin();
    auto pw = graph->weights.cbegin();
    auto pl = graph->layers.cbegin();
    auto p_dst = dst.begin();
    auto p_weights = weights.begin();
    auto p_layers = layers.begin();
    auto p_src = src.begin();
    for (vid_t i = 0; i < graph->nvertices; ++i) {
      const degree_t k = graph->degrees[i];
      for (degree_t j = 0; j < k; ++j, p++, pw++, pl++, p_dst++, p_src++, p_weights++, p_layers++) {
        (*p_dst) = *p;
        (*p_src) = i;
        (*p_weights) = *pw;
        (*p_layers) = *pl;
      }
    }
    return DataFrame::create(
      Named("src") = src + 1L,
      Named("dst") = dst + 1L,
      Named("weights") = weights,
      Named("layer") = layers
    );
  } else {
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
  if (normalise) normalise_weights_by_layer(*graph);
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

// [[Rcpp::export]]
List decompose_exposure_rcpp(int graphid, std::vector<double> values, 
    std::vector<double> exposure, std::vector<double> weights,
    double alpha) {
  Graph* graph = graphs.at(graphid);
  if (graph == 0) throw exception("Graph has been freed.");
  const std::vector<DoubleVec> result = decompose_exposure(*graph, values, 
      exposure, weights, alpha);
  List res(result.size());
  for (size_t i = 0; i < result.size(); ++i) {
    NumericVector r = NumericVector::import(result[i].cbegin(), result[i].cend());;
    res[i] = r;
  }
  return res;
}

