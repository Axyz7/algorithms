#include <iostream>

const int BLACK = 0;
const int RED = 1;

struct Node {
  int key;
  int color;
  Node *left, *right, *parent;
  Node(int key)
      : key(key), color(1), left(nullptr), right(nullptr), parent(nullptr) {}
};

class RBTree {

  Node *root;

  void leftRotate(Node *x) {
    Node *y = x->right;
    x->right = y->left;
    if (y->left)
      y->left->parent = x;
    y->parent = x->parent;
    if (!y->parent)
      root = y;
    else if (x == x->parent->left)
      x->parent->left = y;
    else
      x->parent->right = y;
    y->left = x;
    x->parent = y;
  }

  void rightRotate(Node *y) {
    Node *x = y->left;
    y->left = x->right;

    if (x->right)
      x->right->parent = y;

    x->parent = y->parent;

    if (!y->parent)
      root = x;
    else if (y == y->parent->left)
      y->parent->left = x;
    else
      y->parent->right = x;

    x->right = y;
    y->parent = x;
  }

  int colorOf(Node *n) { return n ? n->color : BLACK; }

  void insertFixup(Node *z) {
    while (z->parent && z->parent->color == RED) {
      Node *grand = z->parent->parent, *uncle = nullptr;
      if (grand->left == z->parent)
        uncle = grand->right;
      else
        uncle = grand->left;
      //  case 1, unc is red
      if (colorOf(uncle) == RED) {
        grand->color = RED;
        uncle->color = z->parent->color = BLACK;
        z = grand;
      } else {
        // case 2, uncle is black

        if (grand->left == z->parent) { // if parent is left
          if (z == z->parent->right) {  // if z is right child LR
            z = z->parent;
            leftRotate(z);
          }
          // LL
          z->parent->color = BLACK;
          grand->color = RED;
          rightRotate(grand);
        } else {
          if (z == z->parent->left) {
            z = z->parent;
            rightRotate(z);
          }
          z->parent->color = BLACK;
          grand->color = RED;
          leftRotate(grand);
        }
        break;
      }
    }
    root->color = BLACK;
  }

  void printInOrder(Node *node) {
    if (!node)
      return;
    printInOrder(node->left);
    std::cout << node->key << (node->color == RED ? "(R) " : "(B) ");
    printInOrder(node->right);
  }

public:
  RBTree() : root(nullptr) {}

  bool search(int key) {
    Node *curr = root;
    while (curr) {
      if (curr->key == key)
        return true;
      else if (curr->key < key)
        curr = curr->right;
      else
        curr = curr->left;
    }
    return false;
  }

  void insert(int key) {
    Node *z = new Node(key);
    Node *parent = nullptr;
    Node *curr = root;

    while (curr) {
      parent = curr;
      if (key < curr->key)
        curr = curr->left;
      else if (key > curr->key)
        curr = curr->right;
      else {
        delete z;
        return;
      }
    }

    z->parent = parent;
    if (!parent)
      root = z;
    else if (key < parent->key)
      parent->left = z;
    else
      parent->right = z;
    insertFixup(z);
  }

  void display() {
    printInOrder(root);
    std::cout << "\n";
  }
};

int main() {
  RBTree tree;

  std::cout << "Inserting \n";
  int vals[] = {10, 20, 30, 15, 25, 5, 1};
  for (int v : vals) {
    std::cout << "Added " << v << " -> ";
    tree.insert(v);
    tree.display();
  }
  std::cout << "\nSearch\n";
  int searchKeys[] = {15, 99, 5};
  for (int k : searchKeys) {
    std::cout << "Searching for " << k << ": "
              << (tree.search(k) ? "Found!" : "Not found.") << "\n";
  }

  return 0;
}
