#include <iostream>
#include <vector>
using namespace std;

template <typename T> class Stack {

private:
  vector<T> values;

public:
  void addValue(T value) { values.push_back(value); }

  void tester() { cout << "Allocation " << values.capacity(); }
};

int main() {
  Stack<int> num;
  num.tester();
  return 0;
}
