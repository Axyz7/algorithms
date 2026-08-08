#include "../util/test.hpp"
#include <algorithm>
#include <chrono>
#include <iostream>
#include <vector>

void countingSort(std::vector<int> &arr, int exp = 0) {
  if (arr.empty())
    return;
  int n = arr.size(), minVal = 0;
  int maxVal = *std::max_element(arr.begin(), arr.end());
  minVal = *std::min_element(arr.begin(), arr.end());
  int range = maxVal - minVal + 1;
  std::vector<int> count(range, 0), output(n);
  for (int x : arr)
    count[x - minVal]++;
  for (int i = 1; i < range; ++i)
    count[i] += count[i - 1];
  for (int i = n - 1; i >= 0; --i)
    output[--count[arr[i] - minVal]] = arr[i];
  arr = output;
}

void radixSort(std::vector<int> &arr) {
  if (arr.empty())
    return;
  int maxVal = *std::max_element(arr.begin(), arr.end());
  int n = arr.size();
  int count[10];
  std::vector<int> buffer(n), *src = &arr, *dst = &buffer;
  for (int exp = 1; maxVal / exp > 0; exp *= 10) {
    std::fill(std::begin(count), std::end(count), 0);
    for (int i = 0; i < n; ++i) {
      int digit = ((*src)[i] / exp) % 10;
      count[digit]++;
    }
    for (int i = 1; i < 10; ++i) {
      count[i] += count[i - 1];
    }
    for (int i = n - 1; i >= 0; --i) {
      int digit = ((*src)[i] / exp) % 10;
      (*dst)[--count[digit]] = (*src)[i];
    }
    std::swap(src, dst);
  }
  if (src != &arr) {
    arr = buffer;
  }
}

void bucketSort(std::vector<int> &arr) {
  if (arr.empty())
    return;
  int maxVal = *std::max_element(arr.begin(), arr.end());
  int minVal = *std::min_element(arr.begin(), arr.end());
  int bucketCount = std::min(static_cast<int>(arr.size()), 1000);
  double range = static_cast<double>(maxVal - minVal + 1) / bucketCount;
  std::vector<std::vector<int>> buckets(bucketCount);
  for (int num : arr) {
    int bIdx = static_cast<int>((num - minVal) / range);
    if (bIdx >= bucketCount)
      bIdx = bucketCount - 1;
    buckets[bIdx].push_back(num);
  }
  for (int i = 0; i < bucketCount; ++i) {
    std::sort(buckets[i].begin(), buckets[i].end());
  }
  int index = 0;
  for (int i = 0; i < bucketCount; ++i) {
    for (int num : buckets[i]) {
      arr[index++] = num;
    }
  }
}

int main() {
  std::vector<size_t> testSizes = {1000, 10000, 100000, 1000000};
  for (size_t N : testSizes) {
    std::cout << "\n--- Input Size N = " << N << " ---\n";
    std::vector<int> original = generateTestCase(N, InputType::RANDOM);
    auto dataCS = original;
    auto start = std::chrono::steady_clock::now();
    countingSort(dataCS);
    auto end = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> timeCS = end - start;
    std::cout << "Counting Sort -> Time: " << timeCS.count()
              << " ms | Validated: "
              << (std::is_sorted(dataCS.begin(), dataCS.end()) ? "Yes" : "No")
              << "\n";
    auto dataRS = original;
    start = std::chrono::steady_clock::now();
    radixSort(dataRS);
    end = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> timeRS = end - start;
    std::cout << "Radix Sort    -> Time: " << timeRS.count()
              << " ms | Validated: "
              << (std::is_sorted(dataRS.begin(), dataRS.end()) ? "Yes" : "No")
              << "\n";
    auto dataBS = original;
    start = std::chrono::steady_clock::now();
    bucketSort(dataBS);
    end = std::chrono::steady_clock::now();
    std::chrono::duration<double, std::milli> timeBS = end - start;
    std::cout << "Bucket Sort   -> Time: " << timeBS.count()
              << " ms | Validated: "
              << (std::is_sorted(dataBS.begin(), dataBS.end()) ? "Yes" : "No")
              << "\n";
  }
  return 0;
}
