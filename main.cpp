#include <iostream>
#include <optional>

using namespace std;
typedef string str;




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

  return 0;
}
