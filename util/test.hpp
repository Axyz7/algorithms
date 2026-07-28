#pragma once

#include <chrono>
#include <vector>

enum class InputType { RANDOM, SORTED, REVERSE_SORTED, DUPLICATES };
std::vector<int> generateTestCase(size_t size, InputType type);
