#include <iostream>
#include <optional>

using namespace std;

optional<int> number = nullopt;

int main() {

  if (!number.has_value()) {
    cout << "No value present";
  } else {
    cout << "Number is: " << number.value();
  }

  return 0;
}
