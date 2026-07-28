#include "../util/test.hpp"
#include <iostream>
#include <vector>

int partition(std::vector<int> &arr, int low, int high) {
  int pivot = arr[high], j = low;
  for (int i = low; i < high; i++) {
    if (arr[i] <= pivot) {
      std::swap(arr[i], arr[j]);
      j++;
    }
  }
  std::swap(arr[j], arr[high]);
  return j;
}

void quickSort(std::vector<int> &arr, int low, int high) {
  if (low < high) {
    int k = partition(arr, low, high);
    quickSort(arr, low, k - 1);
    quickSort(arr, k + 1, high);
  }
}

int main() {
  // test logic
  std::vector<int> test = {3, 2, 21, 4};
  std::cout << "logic test:\nbefore: ";
  for (auto num : test) {
    std::cout << num << ", ";
  }

  quickSort(test, 0, test.size() - 1);
  std::cout << "\nafter: ";
  for (auto num : test) {
    std::cout << num << ", ";
  }

  std::cout << "\nBenchmarks:\n";
  std::vector<size_t> testSizes = {1000, 5000, 10000};

  for (size_t N : testSizes) {
    std::vector<int> data = generateTestCase(N, InputType::RANDOM);
    std::cout << "First 10 numbers of this array:";
    for (auto i = 0; i < 11; i++) {
      std::cout << data[i] << ", ";
    }
    std::cout << '\n';
    auto start = std::chrono::steady_clock::now();
    quickSort(data, 0, (data.size()) - 1);
    auto end = std::chrono::steady_clock::now();

    std::chrono::duration<double, std::milli> duration = end - start;
    std::cout << "Size: " << N << " | Time: " << duration.count() << " ms\n ";
  }

  return 0;
}
