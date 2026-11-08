
#include <algorithm>
#include <concepts>
#include <iostream>
#include <vector>

using namespace std;

template <typename T>
  requires std::totally_ordered<T>

class DataManager {

private:
  vector<T> values;

public:
  // Add values
  void add(T value) { values.push_back(value); }

  // Display values
  void display() const {

    for (const auto &value : values) {
      cout << value << " ";
    }

    cout << endl;
  }

  // Sort values
  void sortData() { sort(values.begin(), values.end()); }

  // Search for a value
  auto search(T target) const {

    return find(values.begin(), values.end(), target) != values.end();
  }

  // Count values greater than a given number
  auto countGreater(T target) const {

    return count_if(values.begin(), values.end(),
                    [target](const T &value) { return value > target; });
  }
};

int main() {

  DataManager<int> manager;

  manager.add(50);
  manager.add(10);
  manager.add(40);
  manager.add(20);
  manager.add(30);

  cout << "Original values: ";
  manager.display();

  manager.sortData();

  cout << "Sorted values: ";
  manager.display();

  cout << "Search 30: " << manager.search(30) << endl;

  cout << "Values greater than 20: " << manager.countGreater(20) << endl;

  return 0;
}
