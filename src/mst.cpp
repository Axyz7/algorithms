#include <algorithm>
#include <iostream>
#include <queue>
#include <vector>

using namespace std;

struct Edge {
  int src, dest, weight;
  Edge(int s, int d, int w) : src(s), dest(d), weight(w) {}
  bool operator<(const Edge &other) const { return weight < other.weight; }
};

class DisjointSet {
  vector<int> parent, rank; // rank for optimizing unite

public:
  DisjointSet(int n) {
    parent.resize(n);
    rank.resize(n, 0); // level of graph
    for (int i = 0; i < n; i++) {
      parent[i] = i; // initially each node is it's own parent
    }
  }
  int find(int i) {
    if (parent[i] == i) // base case, found the root
      return i;
    return parent[i] = find(parent[i]); // path compression for optimization
  }

  void unite(int x, int y) {
    int rootofX = find(x);
    int rootofY = find(y);
    if (rootofX != rootofY) {
      if (rank[rootofX] <
          rank[rootofY]) { // optimization: set x's parent to y if y is bigger
        parent[rootofX] = rootofY;
      } else if (rank[rootofX] > rank[rootofY]) { // opposite of previous
        parent[rootofY] = rootofX;
      } else { // both are similar size so increase rank
        parent[rootofY] = rootofX;
        rank[rootofX]++;
      }
    }
  }
};

class Graph {
  int V, E;
  vector<Edge> edges;
  vector<vector<pair<int, int>>> adj; // adj list for prims
public:
  Graph(int v, int e) : V(v), E(e) { adj.resize(V); }

  void addEdge(int src, int dest, int weight) {
    edges.push_back({src, dest, weight});
    adj[src].push_back({dest, weight});
    adj[dest].push_back({src, weight}); // both ways as it is an undirected
                                        // graph
  }

  void PrimMST() {
    priority_queue<pair<int, int>, vector<pair<int, int>>,
                   greater<pair<int, int>>>
        pq;

    vector<int> key(V, 1e9);
    vector<int> parent(V, -1);
    vector<bool> inMST(V, false); // Tracks visited vertices

    int startNode = 0;
    key[startNode] = 0;
    pq.push({0, startNode});
  }

  void kruskalMST() {
    vector<Edge> mstedges;
    int totalcost = 0;

    // sort edges first using the operator we created
    vector<Edge> sortededges = edges;
    sort(sortededges.begin(), sortededges.end());

    DisjointSet ds(V);

    for (auto &edge : sortededges) {
      int rootSrc = ds.find(edge.src); // find the roots
      int rootDest = ds.find(edge.dest);

      // if root are different, only then add the edge weight
      if (rootSrc != rootDest) {
        ds.unite(rootSrc, rootDest);
        mstedges.push_back(edge);
        totalcost += edge.weight;
      }
    }

    if (mstedges.size() != V - 1) {
      cout << "\ndisconnected graph mst is not possible.\n";
      return;
    }

    cout << "\nKruskal's mst:\n" << "edge\t weight\n";
    for (auto &edge : mstedges) {
      cout << edge.src << "-" << edge.dest << "\t" << edge.weight << "\n";
    }
    cout << "total mini cost: " << totalcost << "\n";
  }
};

int main() {
  int V, E;
  cout << "Enter the number of vertices: ";
  cin >> V;
  cout << "Enter the number of edges: ";
  cin >> E;

  Graph g(V, E);

  cout << "Enter the edges (source destination weight):\n";
  for (int i = 0; i < E; i++) {
    int src, dest, weight;
    cin >> src >> dest >> weight;
    g.addEdge(src, dest, weight);
  }
  g.kruskalMST();

  return 0;
}
