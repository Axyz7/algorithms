#include <algorithm>
#include <iostream>
#include <limits>
#include <vector>

class BHeap {
  struct Tree {
    int key;
    int degree;
    Tree *parent;
    Tree *child;
    Tree *sibling;

    Tree(int key)
        : key(key), degree(0), parent(nullptr), child(nullptr),
          sibling(nullptr) {}
  };
  Tree *head = nullptr;
  int size;

public:
  BHeap() { head = nullptr; };
  void insert(int key) {
    unite(head, new Tree(key));
    size++;
  }
  Tree *unite(Tree *x, Tree *y) {

    Tree *newHead = mergeRootLists(x, y);

    if (newHead == nullptr) {
      return nullptr;
    }

    Tree *previous = nullptr;
    Tree *current = newHead;
    Tree *next = current->sibling;
  }
  Tree *mergeRootLists(Tree *x, Tree *y) {
    if (!x)
      return y;
    if (!y)
      return x;
    Tree *result = nullptr, *tail = nullptr;
    while (x && y) {
      Tree *z;
      if (x->degree <= y->degree) {
        z = x;
        x = x->sibling;
      } else {
        z = y;
        y = y->sibling;
      }
      if (!result) {
        result = z;
        tail = z;
      } else {
        tail->sibling = z;
        tail = z;
      }
    }
    tail->sibling = x ? x : y;
    return result;
  }
  void linkTrees(Tree *child, Tree *parent) {
    child->parent = parent;

    child->sibling = parent->child;
    parent->child = child;

    parent->degree++;
  }
};
