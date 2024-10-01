#ifndef decompose_exposure_h
#define decompose_exposure_h

#include "graph.h"
#include <vector>

typedef std::vector<double> DoubleVec;

std::vector<DoubleVec> decompose_exposure(const Graph& graph,
    const DoubleVec& values, const DoubleVec& exposure, 
    const DoubleVec& weights, double alpha = 0.85);

#endif
