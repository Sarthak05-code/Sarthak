#pragma once

#include <algorithm>
#include <iostream>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <vector>

using namespace std;
typedef string str;
typedef long long ll;
typedef unsigned long long ull;
typedef unsigned long ul;

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

  string getName() { return name; }

  int getAge() { return age; }

  int returnHighestValue() {
      if (data.empty()) {
          throw runtime_error("Cannot find the max value in the empty vector.");
      }

      return *max_element(data.begin(), data.end());
  }
};
