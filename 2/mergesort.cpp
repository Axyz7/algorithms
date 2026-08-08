
#include "../util/test.hpp"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <vector>

void merge(std::vector<int> &arr, std::vector<int> &temp, int left, int mid,
           int right) {
  int len1 = mid - left + 1;
  for (int i = 0; i < len1; ++i) {
    temp[i] = arr[left + i];
  }
  int i = 0;
  int j = mid + 1;
  int k = left;
  while (i < len1 && j <= right) {
    if (temp[i] <= arr[j]) {
      arr[k++] = temp[i++];
    } else {
      arr[k++] = arr[j++];
    }
  }
  while (i < len1) {
    arr[k++] = temp[i++];
  }
}

void mergeSortHelper(std::vector<int> &arr, std::vector<int> &temp, int left,
                     int right) {
  int mid = left + (right - left) / 2;
  mergeSortHelper(arr, temp, left, mid);
  mergeSortHelper(arr, temp, mid + 1, right);
  if (arr[mid] <= arr[mid + 1]) {
    return;
  }
  merge(arr, temp, left, mid, right);
}

void mergeSort(std::vector<int> &arr, int left, int right) {
  if (left >= right)
    return;
  std::vector<int> temp((right - left + 1) / 2 + 1);
  mergeSortHelper(arr, temp, left, right);
}

void printFirst10(const std::vector<int> &arr) {
  size_t count = std::min(size_t(10), arr.size());
  for (size_t i = 0; i < count; i++) {
    std::cout << arr[i] << (i == count - 1 ? "" : ", ");
  }
  std::cout << "\n";
}

int main() {
  std::cout << " Logic Correctness Test \n";
  std::vector<int> test = {38, 27, 43, 3, 9, 82, 10};
  std::cout << "Before sorting: ";
  printFirst10(test);

  mergeSort(test, 0, test.size() - 1);

  std::cout << "After sorting:  ";
  printFirst10(test);
  std::cout << "\n";

  std::cout << " Merge Sort Benchmarks \n";
  std::vector<size_t> testSizes = {1000, 5000, 10000, 100000};
  std::vector<std::pair<std::string, InputType>> testTypes = {
      {"Random Data", InputType::RANDOM},
      {"Sorted Data", InputType::SORTED},
      {"Reverse Sorted", InputType::REVERSE_SORTED}};

  for (auto &[name, type] : testTypes) {
    std::cout << "\nTesting " << name << ":\n";
    for (size_t N : testSizes) {
      std::vector<int> data = generateTestCase(N, type);

      auto start = std::chrono::steady_clock::now();
      mergeSort(data, 0, data.size() - 1);
      auto end = std::chrono::steady_clock::now();

      std::chrono::duration<double, std::milli> duration = end - start;
      std::cout << "Size: " << N << " | Time: " << duration.count() << " ms"
                << " | Validated: "
                << (std::is_sorted(data.begin(), data.end()) ? "Yes" : "No")
                << "\n";
    }
  }
  return 0;
}
