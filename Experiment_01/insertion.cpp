#include <iostream>
#include <vector>

void insertionSort(std::vector<int> &arr) {
  for (int i = 1; i < arr.size(); i++) {
    int j = i, key = arr[i];
    while (j > 0 && key < arr[j - 1]) {
      arr[j] = arr[j - 1];
      j--;
    }
    arr[j] = key;
  }
}

int main() {
  std::vector<int> test = {12, 35, 3, 1, 2};
  insertionSort(test);
  for (int num : test) {
    std::cout << num << ", ";
  }
  return 0;
}
