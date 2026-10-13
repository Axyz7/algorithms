#include "test.hpp"
#include <chrono>
#include <cmath>
#include <iomanip>
#include <iostream>
#include <queue>
#include <vector>

// ---------------- Binomial Heap ----------------
struct BinNode {
  int key, degree;
  BinNode *parent, *child, *sibling;
  BinNode(int k)
      : key(k), degree(0), parent(nullptr), child(nullptr), sibling(nullptr) {}
};

class BinomialHeap {
  BinNode *head = nullptr;

  static BinNode *mergeRoots(BinNode *a, BinNode *b) {
    BinNode dummy(0), *tail = &dummy;
    while (a && b) {
      if (a->degree <= b->degree) {
        tail->sibling = a;
        a = a->sibling;
      } else {
        tail->sibling = b;
        b = b->sibling;
      }
      tail = tail->sibling;
    }
    tail->sibling = a ? a : b;
    return dummy.sibling;
  }
  static void link(BinNode *y, BinNode *z) {
    y->parent = z;
    y->sibling = z->child;
    z->child = y;
    z->degree++;
  }
  BinNode *unionHeaps(BinNode *h1, BinNode *h2) {
    BinNode *h = mergeRoots(h1, h2);
    if (!h)
      return nullptr;
    BinNode *prev = nullptr, *cur = h, *next = cur->sibling;
    while (next) {
      if (cur->degree != next->degree ||
          (next->sibling && next->sibling->degree == cur->degree)) {
        prev = cur;
        cur = next;
      } else if (cur->key <= next->key) {
        cur->sibling = next->sibling;
        link(next, cur);
      } else {
        if (!prev)
          h = next;
        else
          prev->sibling = next;
        link(cur, next);
        cur = next;
      }
      next = cur->sibling;
    }
    return h;
  }

public:
  void insert(int k) {
    BinNode *n = new BinNode(k);
    head = unionHeaps(head, n);
  }
  int findMin() {
    int m = head->key;
    for (BinNode *c = head; c; c = c->sibling)
      if (c->key < m)
        m = c->key;
    return m;
  }
  int extractMin() {
    if (!head)
      return -1;
    BinNode *minPrev = nullptr, *minNode = head;
    BinNode *prev = nullptr, *cur = head;
    while (cur) {
      if (cur->key < minNode->key) {
        minNode = cur;
        minPrev = prev;
      }
      prev = cur;
      cur = cur->sibling;
    }
    if (minPrev)
      minPrev->sibling = minNode->sibling;
    else
      head = minNode->sibling;

    BinNode *child = minNode->child, *rev = nullptr;
    while (child) {
      BinNode *nx = child->sibling;
      child->sibling = rev;
      child->parent = nullptr;
      rev = child;
      child = nx;
    }
    head = unionHeaps(head, rev);
    int res = minNode->key;
    delete minNode;
    return res;
  }
  bool empty() { return head == nullptr; }
  void print() {
    if (!head) {
      std::cout << "  (empty)\n";
      return;
    }
    int idx = 0;
    for (BinNode *r = head; r; r = r->sibling, idx++) {
      std::cout << "  Tree B" << r->degree << " (root=" << r->key << "): ";
      std::queue<std::pair<BinNode *, int>> q;
      q.push({r, 0});
      int lvl = -1;
      while (!q.empty()) {
        auto [n, l] = q.front();
        q.pop();
        if (l != lvl) {
          std::cout << "| L" << l << ": ";
          lvl = l;
        }
        std::cout << n->key << " ";
        for (BinNode *c = n->child; c; c = c->sibling)
          q.push({c, l + 1});
      }
      std::cout << "\n";
    }
  }
};

// ---------------- Fibonacci Heap ----------------
struct FibNode {
  int key, degree;
  bool mark;
  FibNode *parent, *child, *left, *right;
  FibNode(int k)
      : key(k), degree(0), mark(false), parent(nullptr), child(nullptr) {
    left = right = this;
  }
};

class FibonacciHeap {
  FibNode *minNode = nullptr;
  int n = 0;

  void addToRoot(FibNode *x) {
    if (!minNode) {
      minNode = x;
      x->left = x->right = x;
      return;
    }
    x->left = minNode;
    x->right = minNode->right;
    minNode->right->left = x;
    minNode->right = x;
    if (x->key < minNode->key)
      minNode = x;
  }
  void link(FibNode *y, FibNode *x) {
    y->left->right = y->right;
    y->right->left = y->left;
    y->parent = x;
    if (!x->child) {
      x->child = y;
      y->left = y->right = y;
    } else {
      y->left = x->child;
      y->right = x->child->right;
      x->child->right->left = y;
      x->child->right = y;
    }
    x->degree++;
    y->mark = false;
  }
  void consolidate() {
    int D = (int)std::floor(std::log2(n)) + 2;
    std::vector<FibNode *> A(D + 1, nullptr);
    std::vector<FibNode *> roots;
    FibNode *cur = minNode;
    if (cur) {
      do {
        roots.push_back(cur);
        cur = cur->right;
      } while (cur != minNode);
    }
    for (FibNode *w : roots) {
      FibNode *x = w;
      int d = x->degree;
      while (d < (int)A.size() && A[d]) {
        FibNode *y = A[d];
        if (y->key < x->key)
          std::swap(x, y);
        link(y, x);
        A[d] = nullptr;
        d++;
        if (d >= (int)A.size())
          A.push_back(nullptr);
      }
      if (d >= (int)A.size())
        A.resize(d + 1, nullptr);
      A[d] = x;
    }
    minNode = nullptr;
    for (FibNode *a : A) {
      if (!a)
        continue;
      a->left = a->right = a;
      a->parent = nullptr;
      addToRoot(a);
    }
  }

public:
  void insert(int k) {
    FibNode *x = new FibNode(k);
    addToRoot(x);
    n++;
  }
  int findMin() { return minNode->key; }
  int extractMin() {
    FibNode *z = minNode;
    if (!z)
      return -1;
    if (z->child) {
      FibNode *c = z->child;
      do {
        c->parent = nullptr;
        c = c->right;
      } while (c != z->child);
      FibNode *zL = z->left;
      FibNode *cL = z->child->left;
      zL->right = z->child;
      z->child->left = zL;
      cL->right = z;
      z->left = cL;
    }
    z->left->right = z->right;
    z->right->left = z->left;
    int res = z->key;
    if (z == z->right)
      minNode = nullptr;
    else {
      minNode = z->right;
      consolidate();
    }
    n--;
    delete z;
    return res;
  }
  bool empty() { return minNode == nullptr; }
  void print() {
    if (!minNode) {
      std::cout << "  (empty)\n";
      return;
    }
    std::cout << "  Min = " << minNode->key << ", n = " << n << "\n";
    int t = 0;
    FibNode *r = minNode;
    do {
      std::cout << "  Root " << t++ << " (key=" << r->key
                << ", deg=" << r->degree << "): ";
      std::queue<std::pair<FibNode *, int>> q;
      q.push({r, 0});
      int lvl = -1;
      while (!q.empty()) {
        auto [n, l] = q.front();
        q.pop();
        if (l != lvl) {
          std::cout << "| L" << l << ": ";
          lvl = l;
        }
        std::cout << n->key << " ";
        if (n->child) {
          FibNode *c = n->child;
          do {
            q.push({c, l + 1});
            c = c->right;
          } while (c != n->child);
        }
      }
      std::cout << "\n";
      r = r->right;
    } while (r != minNode);
  }
};

int main() {
  std::cout << "Correctness Test\n";
  std::cout << "Insert: 10 20 5 6 12 30 7 17 25 40\n\n";
  std::vector<int> vals = {10, 20, 5, 6, 12, 30, 7, 17, 25, 40};

  std::cout << "--- Binomial Heap ---\n";
  BinomialHeap bh;
  for (int v : vals) {
    bh.insert(v);
    std::cout << "After insert(" << v << "):\n";
    bh.print();
  }
  std::cout << "Find-Min = " << bh.findMin() << "\n\n";
  for (int i = 0; i < 3; i++) {
    int m = bh.extractMin();
    std::cout << "After extractMin() = " << m << ":\n";
    bh.print();
  }

  std::cout << "\n--- Fibonacci Heap ---\n";
  FibonacciHeap fh;
  for (int v : vals) {
    fh.insert(v);
    std::cout << "After insert(" << v << "):\n";
    fh.print();
  }
  std::cout << "Find-Min = " << fh.findMin() << "\n\n";
  for (int i = 0; i < 3; i++) {
    int m = fh.extractMin();
    std::cout << "After extractMin() = " << m << ":\n";
    fh.print();
  }

  std::cout << "\nPerformance Benchmarks (Random Input)\n";
  std::vector<size_t> sizes = {1000, 10000, 50000, 100000, 500000};
  for (size_t N : sizes) {
    std::vector<int> data = generateTestCase(N, InputType::RANDOM);

    BinomialHeap b;
    auto t0 = std::chrono::steady_clock::now();
    for (int v : data)
      b.insert(v);
    auto t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> bIns = t1 - t0;
    t0 = std::chrono::steady_clock::now();
    for (size_t i = 0; i < N / 2; i++)
      b.extractMin();
    t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> bDel = t1 - t0;

    FibonacciHeap f;
    t0 = std::chrono::steady_clock::now();
    for (int v : data)
      f.insert(v);
    t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> fIns = t1 - t0;
    t0 = std::chrono::steady_clock::now();
    for (size_t i = 0; i < N / 2; i++)
      f.extractMin();
    t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> fDel = t1 - t0;

    std::cout << "N=" << std::setw(6) << N << " | Bin  Ins:" << std::setw(8)
              << std::fixed << std::setprecision(2) << bIns.count() << "ms"
              << " Del:" << std::setw(8) << bDel.count() << "ms"
              << " | Fib  Ins:" << std::setw(8) << fIns.count() << "ms"
              << " Del:" << std::setw(8) << fDel.count() << "ms\n";
  }
  return 0;
}
