#pragma once
#include <cstddef>
#include <iostream>
#include <string>
#include <vector>

using namespace std;
template <typename T> T returnNumber(const T &a, const T &b) { return a + b; }

static inline char namecaller(int character) {
  return static_cast<char>(character);
}
// T for the data type.
template <typename T> void displayVector(vector<T> datas) {
  for (size_t i = 0; i < datas.size(); ++i) {
    cout << datas[i] << " ";
  }
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
