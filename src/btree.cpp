#include "test.hpp"
#include <chrono>
#include <iomanip>
#include <iostream>
#include <queue>
#include <string>
#include <vector>

struct BTreeNode {
  std::vector<int> keys;
  std::vector<BTreeNode *> children;
  bool leaf;
  BTreeNode(bool isLeaf) : leaf(isLeaf) {}
};

class BTree {
  int t;
  BTreeNode *root;

  void splitChild(BTreeNode *parent, int i) {
    BTreeNode *full = parent->children[i];
    BTreeNode *neo = new BTreeNode(full->leaf);
    parent->keys.insert(parent->keys.begin() + i, full->keys[t - 1]);
    parent->children.insert(parent->children.begin() + i + 1, neo);
    neo->keys.assign(full->keys.begin() + t, full->keys.end());
    full->keys.resize(t - 1);
    if (!full->leaf) {
      neo->children.assign(full->children.begin() + t, full->children.end());
      full->children.resize(t);
    }
  }
  void insertNonFull(BTreeNode *node, int key) {
    int i = (int)node->keys.size() - 1;
    if (node->leaf) {
      node->keys.push_back(0);
      while (i >= 0 && key < node->keys[i]) {
        node->keys[i + 1] = node->keys[i];
        i--;
      }
      node->keys[i + 1] = key;
    } else {
      while (i >= 0 && key < node->keys[i])
        i--;
      i++;
      if ((int)node->children[i]->keys.size() == 2 * t - 1) {
        splitChild(node, i);
        if (key > node->keys[i])
          i++;
      }
      insertNonFull(node->children[i], key);
    }
  }
  bool searchNode(BTreeNode *node, int key) {
    if (!node)
      return false;
    int i = 0;
    while (i < (int)node->keys.size() && key > node->keys[i])
      i++;
    if (i < (int)node->keys.size() && node->keys[i] == key)
      return true;
    if (node->leaf)
      return false;
    return searchNode(node->children[i], key);
  }

  int getPred(BTreeNode *node, int idx) {
    BTreeNode *cur = node->children[idx];
    while (!cur->leaf)
      cur = cur->children[cur->keys.size()];
    return cur->keys.back();
  }
  int getSucc(BTreeNode *node, int idx) {
    BTreeNode *cur = node->children[idx + 1];
    while (!cur->leaf)
      cur = cur->children[0];
    return cur->keys[0];
  }

  void merge(BTreeNode *node, int idx) {
    BTreeNode *child = node->children[idx];
    BTreeNode *sibling = node->children[idx + 1];
    child->keys.push_back(node->keys[idx]);
    for (int k : sibling->keys)
      child->keys.push_back(k);
    if (!child->leaf)
      for (auto *c : sibling->children)
        child->children.push_back(c);
    node->keys.erase(node->keys.begin() + idx);
    node->children.erase(node->children.begin() + idx + 1);
    delete sibling;
  }
  void fill(BTreeNode *node, int idx) {
    if (idx != 0 && (int)node->children[idx - 1]->keys.size() >= t)
      borrowFromPrev(node, idx);
    else if (idx != (int)node->keys.size() &&
             (int)node->children[idx + 1]->keys.size() >= t)
      borrowFromNext(node, idx);
    else {
      if (idx != (int)node->keys.size())
        merge(node, idx);
      else
        merge(node, idx - 1);
    }
  }

  void borrowFromPrev(BTreeNode *node, int idx) {
    BTreeNode *child = node->children[idx];
    BTreeNode *sib = node->children[idx - 1];
    child->keys.insert(child->keys.begin(), node->keys[idx - 1]);
    if (!child->leaf)
      child->children.insert(child->children.begin(), sib->children.back());
    node->keys[idx - 1] = sib->keys.back();
    sib->keys.pop_back();
    if (!sib->leaf)
      sib->children.pop_back();
  }
  void borrowFromNext(BTreeNode *node, int idx) {
    BTreeNode *child = node->children[idx];
    BTreeNode *sib = node->children[idx + 1];
    child->keys.push_back(node->keys[idx]);
    if (!child->leaf)
      child->children.push_back(sib->children[0]);
    node->keys[idx] = sib->keys[0];
    sib->keys.erase(sib->keys.begin());
    if (!sib->leaf)
      sib->children.erase(sib->children.begin());
  }

  void removeFromNode(BTreeNode *node, int key) {
    int idx = 0;
    while (idx < (int)node->keys.size() && node->keys[idx] < key)
      idx++;

    if (idx < (int)node->keys.size() && node->keys[idx] == key) {
      if (node->leaf) {
        node->keys.erase(node->keys.begin() + idx);
      } else if ((int)node->children[idx]->keys.size() >= t) {
        int pred = getPred(node, idx);
        node->keys[idx] = pred;
        removeFromNode(node->children[idx], pred);
      } else if ((int)node->children[idx + 1]->keys.size() >= t) {
        int succ = getSucc(node, idx);
        node->keys[idx] = succ;
        removeFromNode(node->children[idx + 1], succ);
      } else {
        merge(node, idx);
        removeFromNode(node->children[idx], key);
      }
    } else {
      if (node->leaf)
        return;
      bool last = (idx == (int)node->keys.size());
      if ((int)node->children[idx]->keys.size() < t)
        fill(node, idx);
      if (last && idx > (int)node->keys.size())
        removeFromNode(node->children[idx - 1], key);
      else
        removeFromNode(node->children[idx], key);
    }
  }

  void inorderHelper(BTreeNode *node) {
    if (!node)
      return;
    for (int i = 0; i < (int)node->keys.size(); i++) {
      if (!node->leaf)
        inorderHelper(node->children[i]);
      std::cout << node->keys[i] << " ";
    }
    if (!node->leaf)
      inorderHelper(node->children[node->keys.size()]);
  }
  void preorderHelper(BTreeNode *node) {
    if (!node)
      return;
    for (int k : node->keys)
      std::cout << k << " ";
    if (!node->leaf)
      for (auto *c : node->children)
        preorderHelper(c);
  }
  void postorderHelper(BTreeNode *node) {
    if (!node)
      return;
    if (!node->leaf)
      for (auto *c : node->children)
        postorderHelper(c);
    for (int k : node->keys)
      std::cout << k << " ";
  }
  void destroy(BTreeNode *node) {
    if (!node)
      return;
    if (!node->leaf)
      for (auto *c : node->children)
        destroy(c);
    delete node;
  }

public:
  BTree(int minDeg) : t(minDeg), root(nullptr) {}
  ~BTree() { destroy(root); }

  void insert(int key) {
    if (!root) {
      root = new BTreeNode(true);
      root->keys.push_back(key);
      return;
    }
    if ((int)root->keys.size() == 2 * t - 1) {
      BTreeNode *s = new BTreeNode(false);
      s->children.push_back(root);
      root = s;
      splitChild(s, 0);
      insertNonFull(s, key);
    } else {
      insertNonFull(root, key);
    }
  }
  bool search(int key) { return searchNode(root, key); }
  void remove(int key) {
    if (!root)
      return;
    removeFromNode(root, key);
    if (root->keys.empty()) {
      BTreeNode *old = root;
      root = root->leaf ? nullptr : root->children[0];
      delete old;
    }
  }
  void printLevelOrder() {
    if (!root) {
      std::cout << "  (empty)\n";
      return;
    }
    std::queue<std::pair<BTreeNode *, int>> q;
    q.push({root, 0});
    int curLevel = -1;
    while (!q.empty()) {
      auto [node, lvl] = q.front();
      q.pop();
      if (lvl != curLevel) {
        if (curLevel != -1)
          std::cout << "\n";
        std::cout << "  Level " << lvl << ": ";
        curLevel = lvl;
      }
      std::cout << "[";
      for (int i = 0; i < (int)node->keys.size(); i++) {
        if (i)
          std::cout << " ";
        std::cout << node->keys[i];
      }
      std::cout << "] ";
      if (!node->leaf)
        for (auto *c : node->children)
          q.push({c, lvl + 1});
    }
    std::cout << "\n";
  }
  void printTraversals(const std::string &label) {
    std::cout << label << ":\n";
    std::cout << "  In:   ";
    inorderHelper(root);
    std::cout << "\n";
    std::cout << "  Pre:  ";
    preorderHelper(root);
    std::cout << "\n";
    std::cout << "  Post: ";
    postorderHelper(root);
    std::cout << "\n";
  }
};

int main() {
  int t = 3;
  std::cout << "Minimum degree (t): " << t << "\n";
  std::cout << "Correctness Test\n";
  std::cout << "Insert: 10 20 5 6 12 30 7 17 25 40 3 15 22 35 50\n\n";

  BTree bt(t);
  std::vector<int> vals = {10, 20, 5, 6,  12, 30, 7, 17,
                           25, 40, 3, 15, 22, 35, 50};
  for (int v : vals)
    bt.insert(v);

  std::cout << "B-Tree structure:\n";
  bt.printLevelOrder();
  std::cout << "\n";
  bt.printTraversals("Traversals (after insertion)");

  std::cout << "\nSearch (25) -> " << (bt.search(25) ? "Found" : "Not Found")
            << "\n";
  std::cout << "Search (99) -> " << (bt.search(99) ? "Found" : "Not Found")
            << "\n\n";

  std::vector<int> delKeys = {30, 5};
  for (int key : delKeys) {
    std::cout << "Delete " << key << ":\n";
    bt.remove(key);
    bt.printLevelOrder();
    bt.printTraversals("  Tree");
    std::cout << "\n";
  }

  std::cout << "Performance Benchmarks (Random Input, t=" << t << ")\n";
  std::vector<size_t> sizes = {1000, 10000, 50000, 100000, 500000};

  for (size_t N : sizes) {
    std::vector<int> data = generateTestCase(N, InputType::RANDOM);
    BTree tree(t);

    auto t0 = std::chrono::steady_clock::now();
    for (int v : data)
      tree.insert(v);
    auto t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> ins = t1 - t0;

    t0 = std::chrono::steady_clock::now();
    for (int v : data)
      tree.search(v);
    t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> srch = t1 - t0;

    t0 = std::chrono::steady_clock::now();
    for (size_t i = 0; i < data.size() / 2; ++i)
      tree.remove(data[i]);
    t1 = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> del = t1 - t0;

    std::cout << "N=" << std::setw(6) << N << " | Ins:" << std::setw(8)
              << std::fixed << std::setprecision(2) << ins.count() << "ms"
              << " Src:" << std::setw(8) << srch.count() << "ms"
              << " Del:" << std::setw(8) << del.count() << "ms\n";
  }
  return 0;
}
