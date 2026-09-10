#include "test.hpp"
#include <algorithm>
#include <iostream>
#include <numeric>
#include <random>

std::vector<int> generateTestCase(size_t size, InputType type) {
  std::vector<int> arr(size);

  switch (type) {
  case InputType::RANDOM: {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<int> dist(1, 1000000);
    for (size_t i = 0; i < size; ++i)
      arr[i] = dist(gen);
    break;
  }
  case InputType::SORTED: {
    std::iota(arr.begin(), arr.end(), 1);
    break;
  }
  case InputType::REVERSE_SORTED: {
    std::iota(arr.rbegin(), arr.rend(), 1);
    break;
  }
  case InputType::DUPLICATES: {
    std::fill(arr.begin(), arr.end(), 42);
    break;
  }
  }
  return arr;
}

void printFirst10(const std::vector<int> &arr) {
  size_t count = std::min(size_t(10), arr.size());
  for (size_t i = 0; i < count; i++) {
    std::cout << arr[i] << (i == count - 1 ? "" : ", ");
  }
  std::cout << "\n";
}
