#include "../util/test.hpp"
#include <chrono>
#include <iostream>
#include <vector>

bool binarySearch(std::vector<int> arr, int target) {
  int left = 0, right = arr.size() - 1;
  while (left < right) {
    int mid = (left + right) / 2;
    if (arr[mid] == target) {
      return true;
    } else if (arr[mid] < target) {
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }
  return false;
}

bool linearSearch(std::vector<int> arr, int target) {
  for (int i = 0; i < arr.size(); i++) {
    if (arr[i] == target) {
      return true;
    }
  }
  return false;
}

int main() {
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
    binarySearch(data, 3377);
    auto end = std::chrono::steady_clock::now();
    auto start1 = std::chrono::steady_clock::now();
    linearSearch(data, 3377);
    auto end1 = std::chrono::steady_clock::now();

    std::chrono::duration<double, std::milli> duration = end - start,
                                              duration1 = end1 - start1;
    std::cout << "Size: " << N << " || Time: Binary:" << duration.count()
              << " | Linear: " << duration1.count() << " ms\n";
  }
  return 0;
}
