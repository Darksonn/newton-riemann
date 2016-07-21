#ifndef _COLOR_H
#define _COLOR_H
#include <stdint.h>

struct rgb {
  uint8_t r, g, b;
};
struct hsv {
  float h, s, v;
};
struct hsl {
  float h, s, l;
  __host__ __device__
  inline hsl(float _h, float _s, float _l) : h(_h), s(_s), l(_l) {}
};

__host__ __device__
struct rgb HSVtoRGB(struct hsv hsv);
__host__ __device__
struct rgb HSLtoRGB(struct hsl hsl);

#endif // _COLOR_H
