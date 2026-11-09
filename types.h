#pragma once
typedef unsigned long long UUID;

typedef struct {
  UUID number;

} METRO_MIX;

typedef enum Level { Low, Medium, Large } Level;

static inline METRO_MIX Testcaller(UUID value) {
  METRO_MIX mix = {.number = value};
  return mix;
}
static inline UUID enumToMultiplier(Level level) {
  switch (level) {
  case Low:
    return 2;
  case Medium:
    return 5;
  case Large:
    return 10;
  default:
    return 1; // default can be treated as return 1.
  }
}

static inline METRO_MIX levelRaiser(UUID value, Level level) {
  METRO_MIX mix = {.number = value};
  UUID answer = mix.number * enumToMultiplier(level);
  mix.number = answer;
  return mix;
}
