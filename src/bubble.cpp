#include "test.hpp"
#include <algorithm>
#include <chrono>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

void bubbleSort(std::vector<int> &arr) {
  size_t n = arr.size();
  for (size_t i = 0; i < n; ++i) {
    bool swapped = false;
    for (size_t j = 0; j < n - i - 1; ++j) {
      if (arr[j] > arr[j + 1]) {
        std::swap(arr[j], arr[j + 1]);
        swapped = true;
      }
    }
    if (!swapped)
      break;
  }
}

void selectionSort(std::vector<int> &arr) {
  size_t n = arr.size();
  for (size_t i = 0; i < n; ++i) {
    size_t minIdx = i;
    for (size_t j = i + 1; j < n; ++j) {
      if (arr[j] < arr[minIdx]) {
        minIdx = j;
      }
    }
    if (minIdx != i) {
      std::swap(arr[i], arr[minIdx]);
    }
  }
}

int main() {
  std::cout << "Correctness Tests\n";
  std::vector<int> test = {64, 34, 25, 12, 22, 11, 90};
  std::cout << "Original Array: ";
  printFirst10(test);

  auto testBS = test;
  bubbleSort(testBS);
  std::cout << "Bubble Sort:    ";
  printFirst10(testBS);

  auto testSS = test;
  selectionSort(testSS);
  std::cout << "Selection Sort: ";
  printFirst10(testSS);
  std::cout << "\n";

  std::cout << "Performance Benchmarks";
  std::vector<size_t> testSizes = {1000, 5000, 10000};
  std::vector<std::pair<std::string, InputType>> testTypes = {
      {"Random Data", InputType::RANDOM},
      {"Sorted Data", InputType::SORTED},
      {"Reverse Sorted Data", InputType::REVERSE_SORTED}};

  for (const auto &[name, type] : testTypes) {
    std::cout << "\n--- Testing Pattern: " << name << " ---\n";
    for (size_t N : testSizes) {
      std::vector<int> original = generateTestCase(N, type);
      if (N == 1000)
        printFirst10(original);
      // Benchmark Bubble Sort
      auto dataBS = original;
      auto startBS = std::chrono::steady_clock::now();
      bubbleSort(dataBS);
      auto endBS = std::chrono::steady_clock::now();
      std::chrono::duration<double, std::milli> timeBS = endBS - startBS;

      // Benchmark Selection Sort
      auto dataSS = original;
      auto startSS = std::chrono::steady_clock::now();
      selectionSort(dataSS);
      auto endSS = std::chrono::steady_clock::now();
      std::chrono::duration<double, std::milli> timeSS = endSS - startSS;

      std::cout << "N = " << std::setw(5) << N
                << " | Bubble Sort: " << std::setw(9) << std::fixed
                << std::setprecision(4) << timeBS.count() << " ms"
                << " (Valid: "
                << (std::is_sorted(dataBS.begin(), dataBS.end()) ? "Yes" : "No")
                << ")"
                << " | Selection Sort: " << std::setw(9) << timeSS.count()
                << " ms"
                << " (Valid: "
                << (std::is_sorted(dataSS.begin(), dataSS.end()) ? "Yes" : "No")
                << ")\n";
    }
  }
  return 0;
}
