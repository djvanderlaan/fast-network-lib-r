#include "pajek.h"

#include <fstream>
#include <string>
#include <sstream>

Graph read_pajek(std::istream& stream) {
  Graph graph;
  enum state_t {starting, reading_vertices, reading_edges};
  state_t state = starting;
  std::string buffer;
  size_t line = 0;
  while (std::getline(stream, buffer)) {
    ++line;
    if (buffer[0] == '*') {
      if (buffer.substr(0, 9) == "*Vertices") {
        size_t nvertices = std::stol(buffer.substr(10, buffer.size()));
        graph.add_vertex(nvertices-1);
        state = reading_vertices;
      } else if (buffer.substr(0, 6) == "*Edges" || buffer.substr(0, 6) == "*edges") {
        state = reading_edges;
      } else if (buffer.substr(0, 5) == "*Arcs" || buffer.substr(0, 5) == "*Arcs") {
        state = reading_edges;
      } else {
        throw std::runtime_error("Unknown keyword '" + buffer + "' on line " + 
          std::to_string(line) + ".");
      }
    } else if (buffer[0] == '%') {
      // Ignore comments
    } else if (state == reading_vertices) {
      // These are ignored; we only need the number of vertices and this is
      // already given after the *Vertices keyword
    } else if (state == reading_edges) {
      // edges consist of either 2 or three numbers
      std::istringstream s(buffer);
      size_t src, dst;
      s >> src >> dst;
      if (s.fail()) throw std::runtime_error("Error reading edge on line " + 
        std::to_string(line) + ".");
      double weight = 1.0;
      s >> weight;
      graph.add_edge(src-1, dst-1, weight, false);
    }
  }
  graph.update_positions();
  return graph;
}

Graph read_pajek(const std::string& filename) {
  std::ifstream stream(filename);
  return read_pajek(stream);
}

void write_pajek(const Graph& graph, std::ostream& stream) {
  stream << "*Vertices " << graph.nvertices << '\n';
  stream << "*Arcs\n";
  auto p = graph.edges.begin();
  auto pw = graph.weights.begin();
  for (unsigned int i = 0; i < graph.nvertices; ++i) {
    unsigned int k = graph.degrees[i];
    for (unsigned int j = 0; j < k; ++j, ++p, ++pw) {
      stream << i+1 << ' ' << (*p)+1 << ' ' << *pw << '\n';
    }
  }
}

void write_pajek(const Graph& graph, const std::string& filename) {
  std::ofstream stream(filename);
  write_pajek(graph, stream);
}

