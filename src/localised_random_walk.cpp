#include "localised_random_walk.h"
#include "chunk.h"
#include <cmath>
#include <future>

class localised_random_walk_computer {
  public:
    localised_random_walk_computer(const Graph& graph_, 
      const std::vector<double>& values_, const std::vector<double>& weights_,
      const std::vector<double>& alphas_, unsigned int nstep_max_, double precision_) : 
        graph(graph_), values(values_), weights(weights_), 
        alphas(alphas_), nstep(nstep_max_), precision(precision_), 
        xsum(graph.nvertices, 0.0), xcur(graph.nvertices), xprev(values_), 
        wsum(graph.nvertices, 0.0), wcur(graph.nvertices), wprev(weights_) {
      // xprev needs to be initialised to x*weight
      for (vid_t i = 0; i < graph.nvertices; ++i) {
        xprev[i] = xprev[i] * wprev[i];
      }
    }

    bool computation_step_range(vid_t start, vid_t end) {
      vid_t pos = graph.positions[start];
      auto p = graph.edges.cbegin() + pos;
      auto pw = graph.weights.cbegin() + pos;
      size_t nalpha = alphas.size();
      size_t alpha_pos = start % nalpha;
      bool stop = true;
      for (vid_t i = start; i < end; ++i) {
        // Calculate current end result; at the end we can compare the new
        // result to this an decide that our result is accurate enough
        const double yprev = xsum[i]/wsum[i];
        degree_t k = graph.degrees[i];
        xcur[i] = 0.0;
        wcur[i] = 0.0;
        for (degree_t j = 0; j < k; ++j, ++p, ++pw) {
          wcur[i] += (*pw) * wprev[*p];
          xcur[i] += (*pw) * xprev[*p];
        }
        const double alpha = alphas[alpha_pos++];
        if (alpha_pos >= nalpha) alpha_pos = 0;
        wsum[i] += (1-alpha) * wcur[i];
        xsum[i] += (1-alpha) * xcur[i];
        wcur[i] *= alpha;
        xcur[i] *= alpha;
        // Calculate new end result for current vertex and compare to 
        // previous result; when larger than precision set stop to 
        // false.
        const double ynew = xsum[i]/wsum[i];
        stop &= std::isnan(ynew) || std::abs(ynew-yprev) < precision;
      }
      return stop;
    }

    bool computation_step(unsigned int nthreads) {
      nthreads = std::min(graph.nvertices, nthreads);
      if (nthreads <= 1) return computation_step_range(0, graph.nvertices);
      auto chunks = chunk(graph.nvertices, nthreads);

      // Launch threads
      std::vector<std::future<bool>> futures;
      for (unsigned int i = 0; i < nthreads; ++i) {
        futures.emplace_back(
          std::async(std::launch::async, &localised_random_walk_computer::computation_step_range, 
            this, chunks[i], chunks[i+1])
        );
      }
      // Wait for threads to finish and gather results
      bool stop = true;
      for (unsigned int i = 0; i < nthreads; ++i) {
        stop &= futures[i].get();
      }
      return stop;
    }

    unsigned int compute(unsigned int nthreads = 0) {
      unsigned int step = 0;
      for (; step < nstep; ++step) {
        const bool stop = computation_step(nthreads);
        if (stop) break;
        std::swap(xcur, xprev);
        std::swap(wcur, wprev);
      }
      return step;
    }

    std::vector<double> result() {
      std::vector<double> y(graph.nvertices);
      for (vid_t i = 0; i < graph.nvertices; ++i) {
        y[i] = xsum[i]/wsum[i];
      }
      return y;
    }

  private:
    const Graph& graph;
    const std::vector<double>& values;
    const std::vector<double>& weights;
    const std::vector<double>& alphas;
    const unsigned int nstep;
    const double precision;
    std::vector<double> xsum, xcur, xprev;
    std::vector<double> wsum, wcur, wprev;
};


std::vector<double> localised_random_walk(const Graph& graph, 
    const std::vector<double>& values, const std::vector<double>& weights, 
    double alpha, unsigned int nstep_max, double precision, 
    unsigned int nthreads, unsigned int* nstep) {
  std::vector<double> alphas = {alpha};
  return localised_random_walk(graph, values, weights, alphas, 
    nstep_max, precision, nthreads, nstep);
}

std::vector<double> localised_random_walk(const Graph& graph, 
    const std::vector<double>& values, const std::vector<double>& weights, 
    const std::vector<double>& alphas, unsigned int nstep_max, double precision, 
    unsigned int nthreads, unsigned int* nstep) {
  localised_random_walk_computer computer(graph, values, weights, 
    alphas, nstep_max, precision);
  unsigned int n = computer.compute(nthreads);
  if (nstep) (*nstep) = n;
  return computer.result();
}

