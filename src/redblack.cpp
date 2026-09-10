#include <iostream>
#include <vector>
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

  Node *root, *NIL;

  void leftRotate(Node *x) {
    Node *y = x->right;
    x->right = y->left;
    y->left->parent = x;
    y->parent = x->parent;
    if (y->parent == NIL)
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

    x->right->parent = y;

    x->parent = y->parent;

    if (y->parent == NIL)
      root = x;
    else if (y == y->parent->left)
      y->parent->left = x;
    else
      y->parent->right = x;

    x->right = y;
    y->parent = x;
  }

  void insertFixup(Node *z) {
    while (z->parent != NIL && z->parent->color == RED) {

      Node *grand = z->parent->parent, *uncle;
      if (grand->left == z->parent)
        uncle = grand->right;
      else
        uncle = grand->left;
      //  case 1, unc is red
      if (uncle->color == RED) {
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
    if (node == NIL)
      return;
    printInOrder(node->left);
    std::cout << node->key << (node->color == RED ? "(R) " : "(B) ");
    printInOrder(node->right);
  }

  // delete

  void transplant(Node *u, Node *v) {
    if (u->parent == NIL)
      root = v;
    else if (u == u->parent->left)
      u->parent->left = v;
    else
      u->parent->right = v;
    v->parent = u->parent;
  }

  Node *findMin(Node *n) {
    while (n->left != NIL)
      n = n->left;
    return n;
  }

  void deleteFixup(Node *x) {
    while (x != root && x->color == BLACK) {
      if (x == x->parent->left) {
        Node *w = x->parent->right;
        if (w->color == RED) {
          w->color = BLACK;
          w->parent->color = RED;
          leftRotate(x->parent);
          w = x->parent->right;
        }
        if (w->left->color == BLACK && w->right->color == BLACK) {
          w->color = RED;
          x = x->parent;
        } else {
          if (w->right->color == BLACK) {
            w->color = RED;
            w->left->color = BLACK;
            rightRotate(w);
            w = x->parent->right;
          }
          w->color = w->parent->color;
          w->parent->color = BLACK;
          w->right->color = BLACK;
          leftRotate(w->parent);
          x = root;
        }

      } else {
        Node *w = x->parent->left;

        if (w->color == RED) {
          w->color = BLACK;
          x->parent->color = RED;
          rightRotate(x->parent);
          w = x->parent->left;
        }

        if (w->right->color == BLACK && w->left->color == BLACK) {
          w->color = RED;
          x = x->parent;
        } else {
          if (w->left->color == BLACK) {
            w->right->color = BLACK;
            w->color = RED;
            leftRotate(w);
            w = x->parent->left;
          }
          w->color = x->parent->color;
          x->parent->color = BLACK;
          w->left->color = BLACK;
          rightRotate(x->parent);
          x = root;
        }
      }
    }
    x->color = BLACK;
  }

  void destroyTree(Node *node) {
    if (node == NIL)
      return;
    destroyTree(node->left);
    destroyTree(node->right);
    delete node;
  }

public:
  ~RBTree() {
    destroyTree(root);
    delete NIL;
  }
  void remove(int key) {
    Node *z = root;
    while (z != NIL) {
      if (key == z->key)
        break;
      z = key < z->key ? z->left : z->right;
    }
    if (z == NIL)
      return;

    Node *y = z, *x;
    int yOriginalColor = y->color;

    if (z->left == NIL) {
      x = z->right;
      transplant(z, z->right);
    } else if (z->right == NIL) {
      x = z->left;
      transplant(z, z->left);
    } else {
      y = findMin(z->right);
      yOriginalColor = y->color;
      x = y->right;
      if (y->parent == z) {
        x->parent = y;
      } else {
        // successor is deep
        transplant(y, y->right);
        y->right = z->right;
        y->right->parent = y;
      }

      transplant(z, y);
      y->left = z->left;
      y->left->parent = y;
      y->color = z->color;
    }
    delete z;

    if (yOriginalColor == BLACK) {
      deleteFixup(x);
    }
  }

  RBTree() {
    NIL = new Node(0);
    NIL->color = BLACK;
    NIL->left = NIL;
    NIL->right = NIL;
    NIL->parent = NIL;
    root = NIL;
  }

  bool search(int key) {
    Node *curr = root;
    while (curr != NIL) {
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

    z->left = NIL;
    z->right = NIL;
    Node *parent = NIL;
    Node *curr = root;

    while (curr != NIL) {
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
    if (parent == NIL)
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

  std::cout << "========================================\n";
  std::cout << "   RED-BLACK TREE COMPREHENSIVE TEST    \n";
  std::cout << "========================================\n\n";

  // -------------------------------------------------------------
  // 1. INSERTION TEST
  // -------------------------------------------------------------
  std::cout << "[1] Inserting elements...\n";
  std::vector<int> keys = {20, 10, 35, 5, 15, 25, 45, 2, 8, 27, 30};

  for (int key : keys) {
    std::cout << "Inserting " << key << " -> Tree: ";
    tree.insert(key);
    tree.display();
  }

  // -------------------------------------------------------------
  // 2. SEARCH TEST
  // -------------------------------------------------------------
  std::cout << "\n[2] Testing Search...\n";
  for (int query : {15, 27, 99, 2}) {
    std::cout << "Search " << query << ": "
              << (tree.search(query) ? "FOUND [OK]" : "NOT FOUND [X]") << "\n";
  }

  // -------------------------------------------------------------
  // 3. DELETION TESTS (Targeting specific RB delete cases)
  // -------------------------------------------------------------
  std::cout << "\n========================================\n";
  std::cout << "           TESTING DELETIONS            \n";
  std::cout << "========================================\n";

  // Test A: Delete a RED leaf (Easiest case: No fixup needed)
  std::cout << "\n-- Case A: Deleting a RED leaf (2) --\n";
  std::cout << "Before: ";
  tree.display();
  tree.remove(2);
  std::cout << "After : ";
  tree.display();

  // Test B: Delete a node with TWO children where successor is direct child
  // (Tests: y->parent == z and x->parent = y sentinel assignment)
  std::cout << "\n-- Case B: Deleting node with 2 children, successor is "
               "direct child (35) --\n";
  std::cout << "Before: ";
  tree.display();
  tree.remove(35);
  std::cout << "After : ";
  tree.display();

  // Test C: Delete a node with TWO children where successor is DEEP down
  // (Tests: y->parent != z, transplanting y with y->right)
  std::cout << "\n-- Case C: Deleting node with 2 children, successor is deep "
               "(10) --\n";
  std::cout << "Before: ";
  tree.display();
  tree.remove(10);
  std::cout << "After : ";
  tree.display();

  // Test D: Delete a BLACK node that causes a Double-Black propagation (Fixup
  // Case 2/3/4)
  std::cout << "\n-- Case D: Deleting BLACK node to trigger rotations in "
               "deleteFixup (5) --\n";
  std::cout << "Before: ";
  tree.display();
  tree.remove(5);
  std::cout << "After : ";
  tree.display();

  // Test E: Deleting the ROOT node
  std::cout << "\n-- Case E: Deleting the ROOT node (20) --\n";
  std::cout << "Before: ";
  tree.display();
  tree.remove(20);
  std::cout << "After : ";
  tree.display();

  // Test F: Deleting a non-existent key (Should fail gracefully without
  // crashing)
  std::cout << "\n-- Case F: Deleting a key that does NOT exist (999) --\n";
  tree.remove(999);
  std::cout << "Tree remains unchanged: ";
  tree.display();

  // -------------------------------------------------------------
  // 4. TEARDOWN / CLEAR ENTIRE TREE
  // -------------------------------------------------------------
  std::cout << "\n[4] Draining the tree until empty...\n";
  std::vector<int> remaining = {8, 15, 25, 27, 30, 45};
  for (int key : remaining) {
    std::cout << "Removing " << key << " -> ";
    tree.remove(key);
    tree.display();
  }
  return 0;
}
