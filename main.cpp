#include "types.hpp"

#include <cstddef>
#include <iostream>
#include <vector>

using namespace std;

constexpr int numbers = 10;

int main(void) {

  float a = 10.0, b = 22.0;
  float result = returnNumber(a, b);
  cout << "The result is : " << result << endl;
  vector<int> characters = {96, 98, 123, 234, 121, 55, 77, 86, 33, 50};

  for (int character : characters) {
    cout << character << "\t | \t" << namecaller(character) << "\n";
  }
  cout << "\n";

  string name = "Sarthak Thapa";
  int length = name.length();

  for (size_t i = 0; i < length; ++i) {
    cout << name[i] << "\t|\t" << static_cast<int>(name[i])
         << "\n"; // (int)name[i] older version of typecasting;
  }

  return 0;
}
