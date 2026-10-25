#include <iostream>
#include <optional>

using namespace std;
typedef string str;
typedef long long ll;
typedef unsigned long long ull;
typedef unsigned long ul;

optional<int> number = nullopt;

int main() {
  string caller = "Sarthak";

  if (!number.has_value()) {
    cout << "No value present\n";
  } else {
    cout << "Number is: \n" << number.value();
  }

  for (auto c : caller) {
    if (c != 'z')
      continue;
    else
      cout << "Found `z` \n";
  }

  str name = "Sarthak";
  cout << "What is my name -> : " << name << endl;

  ull number = 10;
  cout << "The unsigned long long number is : " << number << endl;

  return 0;
}
