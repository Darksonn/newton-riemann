#ifndef _COLOR_H
#define _COLOR_H
#include <stdint.h>

struct rgb {
  uint8_t r, g, b;
};
struct hsb {
  float h, s, b;
};

__host__ __device__
struct rgb HSBtoRGB(struct hsb hsb);

#endif // _COLOR_H
