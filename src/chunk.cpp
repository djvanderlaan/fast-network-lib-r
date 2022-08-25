#include "chunk.h"
#include <cmath>

std::vector<size_t> chunk(size_t n, size_t nchunks) {
  size_t chunk_size = std::ceil(static_cast<double>(n)/
      static_cast<double>(nchunks));
  std::vector<size_t> result(nchunks+1);
  result[0] = 0;
  for (size_t i = 0; i < nchunks; ++i) {
    result[i+1] = std::min(n, result[i] + chunk_size);
  }
  return result;
}
