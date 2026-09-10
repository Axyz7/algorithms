#include <algorithm>
#include <iostream>
#include <vector>

struct BSTNode {
  int key;
  BSTNode *left;
  BSTNode *right;
  BSTNode(int val) : key(val), left(nullptr), right(nullptr) {}
};

struct AVLNode {
  int key;
  int height;
  AVLNode *left;
  AVLNode *right;
  AVLNode(int val) : key(val), height(1), left(nullptr), right(nullptr) {}
};

template <typename NodePtr> void inorder(NodePtr root) {
  if (!root)
    return;
  inorder(root->left);
  std::cout << root->key << " ";
  inorder(root->right);
}

template <typename NodePtr> void preorder(NodePtr root) {
  if (!root)
    return;
  std::cout << root->key << " ";
  preorder(root->left);
  preorder(root->right);
}

template <typename NodePtr> void postorder(NodePtr root) {
  if (!root)
    return;
  postorder(root->left);
  postorder(root->right);
  std::cout << root->key << " ";
}

template <typename NodePtr>
void printAllTraversals(NodePtr root, const std::string &label) {
  std::cout << "\n--- Traversals (" << label << ") ---\n";
  std::cout << "Inorder:   ";
  inorder(root);
  std::cout << "\n";
  std::cout << "Preorder:  ";
  preorder(root);
  std::cout << "\n";
  std::cout << "Postorder: ";
  postorder(root);
  std::cout << "\n";
}

template <typename NodePtr> NodePtr minNode(NodePtr root) {
  if (!root)
    return nullptr;
  NodePtr curr = root;
  while (curr->left) {
    curr = curr->left;
  }
  return curr;
}

BSTNode *insertBST(BSTNode *root, int key) {
  if (root == nullptr) {
    return new BSTNode(key);
  }
  if (key < root->key) {
    root->left = insertBST(root->left, key);
  } else if (key > root->key) {
    root->right = insertBST(root->right, key);
  } else {
    return root;
  }
  return root;
}

BSTNode *deleteBST(BSTNode *root, int key) {
  if (!root)
    return nullptr;
  if (key < root->key) {
    root->left = deleteBST(root->left, key);
  } else if (key > root->key)
    root->right = deleteBST(root->right, key);
  else {
    if (!root->left) {
      BSTNode *temp = root->right;
      delete root;
      return temp;
    } else if (!root->right) {
      BSTNode *temp = root->left;
      delete root;
      return temp;
    }
    BSTNode *temp = minNode(root->right);
    root->key = temp->key;
    root->right = deleteBST(root->right, temp->key);
  }
  return root;
}

template <typename NodePtr> bool search(NodePtr root, int key) {
  NodePtr curr = root;
  while (curr) {
    if (curr->key == key)
      return true;
    else if (curr->key > key)
      curr = curr->left;
    else
      curr = curr->right;
  }
  return false;
}

int getHeight(AVLNode *node) { return node ? node->height : 0; }

int getBalanceFactor(AVLNode *node) {
  return node ? getHeight(node->left) - getHeight(node->right) : 0;
}

void updateHeight(AVLNode *node) {
  if (node) {
    node->height = 1 + std::max(getHeight(node->left), getHeight(node->right));
  }
}

AVLNode *rotateRight(AVLNode *y) {
  AVLNode *x = y->left, *T2 = x->right;
  x->right = y;
  y->left = T2;

  updateHeight(y);
  updateHeight(x);

  return x;
}

AVLNode *rotateLeft(AVLNode *x) {
  AVLNode *y = x->right, *T2 = y->left;
  y->left = x;
  x->right = T2;

  updateHeight(x);
  updateHeight(y);

  return y;
}

AVLNode *insertAVL(AVLNode *root, int key) {
  if (root == nullptr) {
    return new AVLNode(key);
  }

  if (key < root->key) {
    root->left = insertAVL(root->left, key);
  } else if (key > root->key) {
    root->right = insertAVL(root->right, key);
  } else {
    return root; // Duplicate keys not allowed
  }
  updateHeight(root);
  int balance = getBalanceFactor(root);
  if (balance > 1 && key < root->left->key)
    return rotateRight(root);
  else if (balance < -1 && key > root->right->key)
    return rotateLeft(root);
  else if (balance > 1 && key > root->left->key) {
    root->left = rotateLeft(root->left);
    return rotateRight(root);
  } else if (balance < -1 && key < root->right->key) {
    root->right = rotateRight(root->right);
    return rotateLeft(root);
  }
  return root;
}

AVLNode *deleteAVL(AVLNode *root, int key) {
  if (!root)
    return nullptr;
  if (key < root->key) {
    root->left = deleteAVL(root->left, key);
  } else if (key > root->key)
    root->right = deleteAVL(root->right, key);
  else {
    if (!root->left) {
      AVLNode *temp = root->right;
      delete root;
      root = temp;
    } else if (!root->right) {
      AVLNode *temp = root->left;
      delete root;
      root = temp;
    } else {
      AVLNode *temp = minNode(root->right);
      root->key = temp->key;
      root->right = deleteAVL(root->right, temp->key);
    }
  }
  if (!root)
    return nullptr;
  updateHeight(root);
  int balance = getBalanceFactor(root);
  if (balance > 1) {
    if (getBalanceFactor(root->left) >= 0) {
      return rotateRight(root);
    } else {
      root->left = rotateLeft(root->left);
      return rotateRight(root);
    }
  } else if (balance < -1) {
    if (getBalanceFactor(root->right) <= 0)
      return rotateLeft(root);
    else {
      root->right = rotateRight(root->right);
      return rotateLeft(root);
    }
  }
  return root;
}

int main() {
  BSTNode *bstRoot = nullptr;
  AVLNode *avlRoot = nullptr;

  std::vector<int> testKeys = {10, 20, 30, 40, 50, 25};

  std::cout << "========================================" << std::endl;
  std::cout << "         INSERTION EXPERIMENT           " << std::endl;
  std::cout << "========================================" << std::endl;

  for (int key : testKeys) {
    bstRoot = insertBST(bstRoot, key);
    avlRoot = insertAVL(avlRoot, key);
  }

  printAllTraversals(bstRoot, "BST after insertion");
  printAllTraversals(avlRoot, "AVL after insertion");

  std::cout << "\n========================================" << std::endl;
  std::cout << "          SEARCH EXPERIMENT             " << std::endl;
  std::cout << "========================================" << std::endl;

  int searchKey = 25;
  std::cout << "Searching for " << searchKey << " in BST: "
            << (search(bstRoot, searchKey) ? "Found" : "Not Found")
            << std::endl;
  std::cout << "Searching for " << searchKey << " in AVL: "
            << (search(avlRoot, searchKey) ? "Found" : "Not Found")
            << std::endl;

  std::cout << "\n========================================" << std::endl;
  std::cout << "          DELETION EXPERIMENT           " << std::endl;
  std::cout << "========================================" << std::endl;

  std::vector<int> deleteKeys = {30, 10};
  for (int key : deleteKeys) {
    std::cout << "\n---> Deleting key: " << key << std::endl;
    bstRoot = deleteBST(bstRoot, key);
    avlRoot = deleteAVL(avlRoot, key);

    printAllTraversals(bstRoot, "BST after deleting " + std::to_string(key));
    printAllTraversals(avlRoot, "AVL after deleting " + std::to_string(key));
  }

  return 0;
}
