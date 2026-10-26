#include "types.hpp"
#include <iostream>

using namespace std;

int main() {
  Cache cache;
  cache.setData("Sarthak", 20, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
  auto age = cache.getAge();
  auto name = cache.getName();
  cout << "Your name : " << name << " <-> Your age : " << age << endl;

  cache.display();

  cout << "The highest value in the vector is : " << cache.returnHighestValue()
       << endl;

  return 0;
}
