#include "types.hpp"
#include <iostream>

typedef const char *immutable;
#define mutable string

using namespace std;

int main(int argc, const char **argv) {
  Cache cache;
  immutable name = "Sarthak";
  auto call = name;
  cout << "Name : " << name << endl;
  mutable nam = "Sarthak";
  auto a = nam;
  cout << "-> " << a << endl;

  if (call == a) {
    cout << "Same \n";
  } else {
    cout << "Not same \n";
  }

  if (argc != 2) {
    cout << "Get Fucked. \n";
  }

  return 0;
}
