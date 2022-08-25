#include "generate_poisson.h"
#include <climits>
#include <random>

struct FastRand {
  typedef unsigned int result_type;

  FastRand(unsigned int seed = 0) : g_seed(seed) {}
  
  static constexpr result_type min() {
    return 0;
  }

  static constexpr result_type max() {
    return 32767;
  }

  result_type operator()() {
    g_seed = (214013*g_seed+2531011);
    return (g_seed>>16)&0x7FFF;
  }

  unsigned int g_seed;
};

struct WELL512 {
  typedef uint32_t result_type;
 
  WELL512(unsigned int seed = 0) {
    FastRand rnd0(seed);
    for (unsigned int i = 0; i < 16; ++i) 
      state[i] = rnd0();
  }

  static constexpr result_type min() {
    return 0;
  }

  static constexpr result_type max() {
    return UINT_MAX;
  }

  result_type operator()() {
    unsigned long a, b, c, d;
    a = state[index];
    c = state[(index+13)&15];
    b = a^c^(a<<16)^(c<<15);
    c = state[(index+9)&15];
    c ^= (c>>11);
    a = state[index] = b^c;
    d = a^((a<<5)&0xDA442D24UL);
    index = (index + 15)&15;
    a = state[index];
    state[index] = a^b^d^(a<<2)^(b<<18)^(c<<28);
    return state[index];
  }

  uint32_t state[16];
  uint32_t index = 0;
};

Graph generate_poisson(vid_t nvertices, double mean_degree, unsigned int seed) {
  Graph graph(nvertices);
  if (nvertices == 0) return graph;
  // Step 1 generate the degree for each vertex
  WELL512 gen(seed);
  std::poisson_distribution<> dpois(mean_degree);
  for (vid_t i = 0; i < nvertices; ++i) {
    graph.degrees[i] = dpois(gen);
  }
  graph.update_positions();
  // We now now how many edges there are
  size_t nedges = graph.positions.back() + graph.degrees.back();
  graph.edges.resize(nedges);
  graph.weights.resize(nedges);
  // Step 2 generate the edges for each vertex
  std::uniform_int_distribution<> dint(0, nvertices-1);
  auto pedge = graph.edges.begin();
  auto pw = graph.weights.begin();
  for (vid_t i = 0; i < nvertices; ++i) {
    degree_t k = graph.degrees[i];
    for (vid_t j = 0; j < k; ++j, ++pedge, ++pw) {
       *pedge = dint(gen);
       *pw = 1.0;
    }
  }
  return graph;
}

