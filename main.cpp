#include <iostream>
#include <optional>

using namespace std;
typedef string str;
typedef long long ll;
typedef unsigned long long ull;
typedef unsigned long ul;

#define f(x) (2 * x + 3 ^ x + 1)

ull hasher(int number, bool hash = true) {
  if (hash) {
    return 1923377282;
  }
  return number;
}

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

  auto answer = hasher(1025);
  cout << "The hashed is : " << answer << endl;

  auto ans = f(2);
  cout << "Integer -> " << ans << endl;

  return 0;
}
