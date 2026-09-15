#include <iostream>

#include <variant>
#include <vector>

using namespace std;

variant<string> name = "Sarthak";

template <typename T> void print(T value) { cout << value << "\n"; }

void bubbleSort(vector<int> &numbers, int method = 1) {
  // 1 => ascending order
  // 0 => descending order

  if (method != 1 && method != 0) {
    cout << "Error, in sorting format, pick 1 or 0 only.\n";
    return;
  }

  int length = numbers.size();

  for (int i = 0; i < length - 1; ++i) {

    for (int j = 0; j < length - i - 1; ++j) {

      if (method == 1) {
        // Ascending
        if (numbers[j] > numbers[j + 1]) {
          int temp = numbers[j];
          numbers[j] = numbers[j + 1];
          numbers[j + 1] = temp;
        }
      } else {
        // Descending
        if (numbers[j] < numbers[j + 1]) {
          int temp = numbers[j];
          numbers[j] = numbers[j + 1];
          numbers[j + 1] = temp;
        }
      }
    }
  }
}

int main() {
  vector<int> number = {1, 4, 2, 6, 10, 12, 4, 55, 12};

  bubbleSort(number);
  for (int num : number) {
    cout << num << "\t";
  }
  cout << "\n";
  bubbleSort(number, 0);
  for (int num : number) {
    cout << num << "\t";
  }

  print(10);
  print(10.0);
  print(true);
  print('c');
  print("string");

  return 0;
}
