#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

template <typename T> class RanDex {
private:
  T item;
  vector<T> datas;

public:
  RanDex(T data) { item = data; }
  RanDex(vector<T> datas) { datas = datas; }

  void displayData() { cout << "-> " << item; }

  void sortUnsortedVector() { sort(datas.begin(), datas.end()); }

  void display() {
    for (auto data : datas) {
      cout << " " << data << endl;
    }
  }
};

int main() {
  RanDex<int> rd({10,20,30});
  rd(10)
  return 0;
}
