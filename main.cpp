#include <cstdint>
#include <iomanip>
#include <iostream>
typedef uint64_t i64;

int returnValue(int number_one, int number_two, int value = 1) {
  if (value != 1 && value != 0) {
    std::cout << "The number you entered wasn't a proper value" << "\n";
    return 1;
  }
  if (value == 1)
    return number_one > number_two ? number_one : number_one;
  return number_one > number_two ? number_two : number_one;
}

template <typename T> T findArea(T a, T b) { return a * b; }

int main() {
  int num = 10, ber = 20;
  std::cout << "The number is : " << returnValue(num, ber);
  std::cout << "The number is : " << returnValue(num, ber, 1);

  return 0;
}
