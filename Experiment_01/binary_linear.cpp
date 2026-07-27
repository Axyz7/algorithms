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
  std::vector<int> test = {1, 5, 24, 44, 45};
  int target = 5;
  auto start{std::chrono::steady_clock::now()};
  auto fb{linearSearch(test, target)};
  auto finish{std::chrono::steady_clock::now()};
  std::chrono::duration<double> elapsed_seconds{finish - start};
  std::cout << elapsed_seconds.count() << " for linear search" << '\n';

  start = std::chrono::steady_clock::now();
  fb = binarySearch(test, target);
  finish = std::chrono::steady_clock::now();
  elapsed_seconds = finish - start;
  std::cout << elapsed_seconds.count() << " for binary search" << '\n';

  return 0;
}
