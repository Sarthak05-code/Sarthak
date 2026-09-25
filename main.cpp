#include <iostream>
using namespace std;

template <typename T> class Stack {

private:
  static const int size = 5;
  T length[size];
  int TOP = 0;

public:
  /**
   * Adds a value to the top of the stack.
   *
   * @param value The value to add to the stack.
   * @note Does nothing if the stack is already full.
   */
  void push(T value) {

    if (TOP < size) {
      length[TOP] = value;
      TOP++;
    } else {
      cout << "Stack Overflow" << endl;
    }
  }

  /**
   * Removes the value at the top of the stack.
   *
   * @note This method takes no parameters because it
   *       automatically operates on the top element.
   * @note Displays "Stack Underflow" if the stack is empty.
   */
  void pop() {

    if (TOP > 0) {
      cout << "Value : " << length[TOP - 1] << " popped." << endl;

      TOP--;
    } else {
      cout << "Stack Underflow" << endl;
    }
  }

  /**
   * Displays all values currently stored in the stack.
   *
   * The values are displayed from the bottom of the stack
   * to the top of the stack.
   *
   * @note Does nothing if the stack is empty.
   */
  void release() {

    for (int i = 0; i < TOP; ++i) {
      cout << length[i] << "\n";
    }
  }

  /**
   * Displays the value currently at the top of the stack.
   *
   * @note This method takes no parameters.
   * @note Displays a message if the stack is empty.
   */
  void top() {

    if (TOP > 0) {
      cout << "The top of the stack contains : " << length[TOP - 1] << endl;
    } else {
      cout << "The stack is empty!" << endl;
    }
  }

  /**
   * Finds and displays the maximum value in the stack.
   *
   * The method checks whether the stack is empty before
   * accessing its elements.
   *
   * @note Requires T to support the less-than (<) operator.
   * @note Displays a message if the stack is empty.
   */
  void MaxStackValue() {

    if (TOP == 0) {
      cout << "The stack is empty!" << endl;
      return;
    }

    T max = length[0];

    for (int i = 1; i < TOP; ++i) {
      if (max < length[i]) {
        max = length[i];
      }
    }

    cout << "The max value is : " << max << endl;
  }

  /**
   * Calculates and displays the sum of all values in the stack.
   *
   * The method starts with a zero value and adds every element
   * currently stored in the stack.
   *
   * @note Intended for numeric types such as int, float, and double.
   * @note T must support initialization from 0 and the += operator.
   * @note Displays 0 if the stack is empty.
   */
  void SumAllStackVal() {

    T sum = 0;

    if (TOP == 0) {
      cout << "The sum is 0" << endl;
      return;
    }

    for (int i = 0; i < TOP; ++i) {
      sum += length[i];
    }

    cout << "The sum is : " << sum << endl;
  }
};

int main() {

  Stack<int> stack;

  stack.MaxStackValue();
  stack.SumAllStackVal();

  stack.push(10);
  stack.push(20);
  stack.push(100);
  stack.push(40);

  stack.SumAllStackVal();

  stack.release();

  stack.MaxStackValue();

  stack.top();

  stack.pop();

  stack.top();

  return 0;
}
