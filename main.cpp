
#include <iostream>
using namespace std;

int TOP = 0;
int length[5];
// integer stack for now.
class Stack {

public:
  void push(int value) {
    if (TOP < 5) {
      TOP++;
      length[TOP] = value;
    } else {
      cout << "Stack Overflow" << "\n";
    }
  }

  void pop() {
    if (TOP > 0) {
      TOP--;
    }
  }

  // for context, i named it release.
  void release() {
    for (auto i = 0; i < TOP; ++i) {
      cout << length[i] << "\n";
    }
  }

  void top() {

    if (TOP > 0) {
      cout << length[TOP - 1];
    }
  }
};

int main() {
  Stack stack;
  stack.push(10);
  stack.push(20);
  stack.push(30);
  stack.push(40);
  stack.push(50);
  stack.push(60);
  stack.push(60);
  stack.push(60);
  stack.push(60);
  stack.push(60);
  stack.push(60);
  stack.push(60);
  stack.push(100);
  cout << "\n";
  stack.release();

  cout << "The top of the stack is : " << endl;
  stack.top();

  return 0;
}
