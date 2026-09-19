#pragma once

#include <iostream>
#include <string>
#include <type_traits>
#include <vector>


using namespace std;
template <typename T> T returnNumber(const T &a, const T &b) { return a + b; }

static inline char namecaller(int character) {
  return static_cast<char>(character);
}
// T for the data type.

template <typename T>
void displayVector(const vector<T> &datas, bool return_Cast = false) {
  for (const T &data : datas) {

    if constexpr (std::is_same_v<T, char>) {
      if (return_Cast)
        cout << data << " -> " << static_cast<int>(data) << " ";
      else
        cout << data << " ";
    } else {
      cout << data << " ";
    }
  }
  cout << endl;
}

class Cache {
private:
  string name;
  int age;
  vector<int> data;

public:
  void setData(const string &name, int age, const vector<int> &data) {
    this->data = data;
    this->name = name;
    this->age = age;
  }
  void display() {
    cout << name << " | " << age << " | ";
    displayVector(data);
    cout << "\n";
  }
};
