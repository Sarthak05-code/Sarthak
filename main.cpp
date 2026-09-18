#include "types.hpp"
#include <iostream>
#include <string>
#include <vector>

using namespace std;

constexpr int numbers = 10;

int main(void) {
  Cache cache;
  cache.setData("Sarthak", 20, {1, 2, 3, 4, 5, 6});
  cache.display();

  vector<int> data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  vector<char> chars = {'1', '2', '3', '4', '5'};
  vector<string> names = {"Sarthak", "Sagar", "Aayush", "Ayush"};

  cout << "\n";
  displayVector(data);
  cout << "\n";
  displayVector(chars);
  cout << "\n";
  displayVector(names);

  return 0;
}
