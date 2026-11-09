#include "types.h"
#include <stdio.h>

int main(void) {
  METRO_MIX mix = levelRaiser(100, Low);
  printf("The final answer : %llu.\n", mix.number);
  return 0;
}
