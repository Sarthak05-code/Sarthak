#include <iostream>
#include <queue>
#include <type_traits>

// 1. Primary template trait to check if a type is a std::queue
template <typename T> struct is_queue : std::false_type {};

template <typename T, typename Container>
struct is_queue<std::queue<T, Container>> : std::true_type {};

// 2. Use std::enable_if in the return type (or template parameter)
template <typename T>
typename std::enable_if<is_queue<T>::value, void>::type
process_queue(const T &q) {
  std::cout << "Valid queue received!" << std::endl;
}

int main() {
  std::queue<int> q;
  process_queue(q); // Compiles successfully!

  // std::vector<int> v;
  // process_queue(v); // Compile Error: no matching function for call!

  return 0;
}
