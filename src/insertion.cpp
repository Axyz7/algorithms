#include "../util/test.hpp"
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
  std::cout << "Logic test:\nbefore: ";
  for (int num : test) {
    std::cout << num << ", ";
  }
  insertionSort(test);
  std::cout << "\nafter: ";
  for (int num : test) {
    std::cout << num << ", ";
  }

  std::cout << "\nBenchmarks:\n";
  std::vector<size_t> testSizes = {1000, 5000, 10000};

  for (size_t N : testSizes) {
    std::vector<int> data = generateTestCase(N, InputType::RANDOM);
    std::cout << "First 10 numbers(array):";
    for (auto i = 0; i < 11; i++) {
      std::cout << data[i] << ", ";
    }
    std::cout << '\n';
    auto start = std::chrono::steady_clock::now();
    insertionSort(data);
    auto end = std::chrono::steady_clock::now();

    std::chrono::duration<double, std::milli> duration = end - start;
    std::cout << "Size: " << N << " | Time: " << duration.count() << " ms\n ";
  }
  return 0;
}
