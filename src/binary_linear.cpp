#include "../util/test.hpp"
#include <chrono>
#include <iostream>
#include <vector>

int binarySearch(std::vector<int> &arr, int target) {
  int left = 0, right = arr.size() - 1;
  while (left <= right) {
    int mid = left + (right - left) / 2;

    if (arr[mid] == target) {
      return mid;
    } else if (arr[mid] > target) {
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }
  return -1;
}

int linearSearch(std::vector<int> &arr, int target) {
  for (int i = 0; i < arr.size(); i++) {
    if (arr[i] == target) {
      return i;
    }
  }
  return -1;
}

int main() {
  std::cout << "\n================ Search Benchmarks ================\n";
  std::vector<size_t> testSizes = {1000, 5000, 10000, 100000};

  for (size_t N : testSizes) {
    std::vector<int> data = generateTestCase(N, InputType::SORTED);

    std::cout << "\n[N = " << N << "] First 10 elements (sorted): ";
    size_t printCount = std::min(static_cast<size_t>(10), data.size());
    for (size_t i = 0; i < printCount; ++i) {
      std::cout << data[i] << (i == printCount - 1 ? "" : ", ");
    }
    std::cout << "\n";

    // Select a target that exists in the array (near the end to test linear
    // search)
    int target = data[N - 5];

    auto startLin = std::chrono::steady_clock::now();
    int linIdx = linearSearch(data, target);
    auto endLin = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> linTime = endLin - startLin;

    auto startBin = std::chrono::steady_clock::now();
    int binIdx = binarySearch(data, target);
    auto endBin = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> binTime = endBin - startBin;

    // Output Benchmark Results
    std::cout << "Searching for Target Value: " << target << "\n";
    std::cout << "  Linear Search -> Index: " << linIdx
              << " | Time: " << linTime.count() << " ms\n";
    std::cout << "  Binary Search -> Index: " << binIdx
              << " | Time: " << binTime.count() << " ms\n";
  }

  return 0;
}
