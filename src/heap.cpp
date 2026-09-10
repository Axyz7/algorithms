#include "test.hpp"
#include <algorithm>
#include <chrono>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

void heapify(std::vector<int> &arr, size_t n, size_t i) {
  size_t largest = i;
  size_t left = 2 * i + 1;
  size_t right = 2 * i + 2;
  if (left < n && arr[left] > arr[largest])
    largest = left;
  if (right < n && arr[right] > arr[largest])
    largest = right;
  if (largest != i) {
    std::swap(arr[i], arr[largest]);
    heapify(arr, n, largest);
  }
}

void heapSortWithHeapify(std::vector<int> &arr) {
  size_t n = arr.size();
  if (n <= 1)
    return;
  for (int i = (n) / 2 - 1; i >= 0; --i) {
    heapify(arr, n, (i));
  }
  for (size_t i = n - 1; i > 0; --i) {
    std::swap(arr[0], arr[i]);
    heapify(arr, i, 0);
  }
}

void heapSortWithoutHeapify(std::vector<int> &arr) {
  int n = arr.size();
  for (int i = n / 2 - 1; i >= 0; i--) {
    int curr = i;
    while (true) {
      int largest = curr;
      int left = 2 * curr + 1, right = 2 * curr + 2;
      if (left < n && arr[left] > arr[largest]) {
        largest = left;
      }
      if (right < n && arr[right] > arr[largest]) {
        largest = right;
      }
      if (largest == curr) {
        break;
      }
      std::swap(arr[largest], arr[curr]);
      curr = largest;
    }
  }
  for (int i = n - 1; i > 0; i--) {
    std::swap(arr[0], arr[i]);
    int curr = 0;
    while (true) {
      int largest = curr;
      int left = 2 * curr + 1, right = 2 * curr + 2;
      if (left < i && arr[left] > arr[largest]) {
        largest = left;
      }
      if (right < i && arr[right] > arr[largest]) {
        largest = right;
      }
      if (largest == curr) {
        break;
      }
      std::swap(arr[largest], arr[curr]);
      curr = largest;
    }
  }
}

int main() {
  std::cout << "Correctness Tests\n";
  std::vector<int> test = {64, 34, 25, 12, 22, 11, 90};
  std::cout << "Original Array:  ";
  printFirst10(test);

  auto testWith = test;
  heapSortWithHeapify(testWith);
  std::cout << "With Heapify:    ";
  printFirst10(testWith);

  auto testWithout = test;
  heapSortWithoutHeapify(testWithout);
  std::cout << "Without Heapify: ";
  printFirst10(testWithout);
  std::cout << "\n";

  std::cout << "Performance Benchmarks";
  std::vector<size_t> testSizes = {10000, 50000, 100000};
  std::vector<std::pair<std::string, InputType>> testTypes = {
      {"Random Data", InputType::RANDOM},
      {"Sorted Data", InputType::SORTED},
      {"Reverse Sorted Data", InputType::REVERSE_SORTED}};

  for (const auto &[name, type] : testTypes) {
    std::cout << "\nTesting Pattern: " << name << "\n";
    for (size_t N : testSizes) {
      std::vector<int> original = generateTestCase(N, type);
      if (N == 10000)
        printFirst10(original);

      // Benchmark Heap Sort With Heapify
      auto dataWith = original;
      auto startWith = std::chrono::steady_clock::now();
      heapSortWithHeapify(dataWith);
      auto endWith = std::chrono::steady_clock::now();
      std::chrono::duration<double, std::milli> timeWith = endWith - startWith;

      // Benchmark Heap Sort Without Heapify
      auto dataWithout = original;
      auto startWithout = std::chrono::steady_clock::now();
      heapSortWithoutHeapify(dataWithout);
      auto endWithout = std::chrono::steady_clock::now();
      std::chrono::duration<double, std::milli> timeWithout =
          endWithout - startWithout;

      std::cout
          << "N=" << std::setw(6) << N << "|Heapify:" << std::setw(7)
          << std::fixed << std::setprecision(4) << timeWith.count() << " ms"
          << " (Valid:"
          << (std::is_sorted(dataWith.begin(), dataWith.end()) ? "Yes" : "No")
          << ")"
          << " |No Heapify:" << std::setw(7) << timeWithout.count() << " ms"
          << " (Valid:"
          << (std::is_sorted(dataWithout.begin(), dataWithout.end()) ? "Yes"
                                                                     : "No")
          << ")\n";
    }
  }

  return 0;
}
