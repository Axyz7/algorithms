#include "../util/test.hpp"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <vector>

// --- Lomuto Partition Scheme
int partition(std::vector<int> &arr, int low, int high) {
  int pivot = arr[high];
  int j = low;
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
void printFirst10(const std::vector<int> &arr) {
  size_t count = std::min(size_t(10), arr.size());
  for (size_t i = 0; i < count; i++) {
    std::cout << arr[i] << (i == count - 1 ? "" : ", ");
  }
  std::cout << "\n";
}

int main() {
  std::cout << " Correctness Test \n";
  std::vector<int> test = {3, 2, 21, 4, 1, 15, 8};

  std::cout << "Before sorting: ";
  printFirst10(test);

  quickSort(test, 0, test.size() - 1);

  std::cout << "After sorting:  ";
  printFirst10(test);
  std::cout << "Is Sorted: "
            << (std::is_sorted(test.begin(), test.end()) ? "Yes" : "No")
            << "\n\n";

  std::cout << " Benchmarks \n";
  std::vector<size_t> testSizes = {1000, 5000, 10000};

  std::vector<std::pair<std::string, InputType>> testTypes = {
      {"Random Data", InputType::RANDOM},
      {"Sorted Data", InputType::SORTED},
      {"Reverse Sorted", InputType::REVERSE_SORTED}};

  for (auto &[name, type] : testTypes) {
    std::cout << "\nTesting " << name << ":\n";

    for (size_t N : testSizes) {
      // Avoid stack overflow hazard for naive pivot on sorted data
      if (type != InputType::RANDOM && N >= 10000) {
        std::cout << "Size: " << N << " | Skipped (Stack overflow risk)\n";
        continue;
      }

      std::vector<int> data = generateTestCase(N, type);

      auto start = std::chrono::steady_clock::now();
      quickSort(data, 0, data.size() - 1);
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
