
#include "color.h"

__host__ __device__
inline bool is_weird(float f) {
  return isnan(f) || isinf(f);
}

__host__ __device__
struct rgb HSBtoRGB(struct hsb hsb) {
  struct rgb black;
  black.r = black.g = black.b = 0;
  if (is_weird(hsb.h) || is_weird(hsb.s) || is_weird(hsb.b)) return black;
  uint8_t r,g,b;
  float hue = hsb.h;
  float saturation = hsb.s;
  float brightness = hsb.b;
  if (saturation == 0) {
    r = g = b = (int) (brightness * 255.0f + 0.5f);
  } else {
    float h = (hue - (float)floor(hue)) * 6.0f;
    float f = h - (float)floor(h);
    float p = brightness * (1.0f - saturation);
    float q = brightness * (1.0f - saturation * f);
    float t = brightness * (1.0f - (saturation * (1.0f - f)));
    switch ((int) h) {
      case 0:
        r = (int) (brightness * 255.0f + 0.5f);
        g = (int) (t * 255.0f + 0.5f);
        b = (int) (p * 255.0f + 0.5f);
        break;
      case 1:
        r = (int) (q * 255.0f + 0.5f);
        g = (int) (brightness * 255.0f + 0.5f);
        b = (int) (p * 255.0f + 0.5f);
        break;
      case 2:
        r = (int) (p * 255.0f + 0.5f);
        g = (int) (brightness * 255.0f + 0.5f);
        b = (int) (t * 255.0f + 0.5f);
        break;
      case 3:
        r = (int) (p * 255.0f + 0.5f);
        g = (int) (q * 255.0f + 0.5f);
        b = (int) (brightness * 255.0f + 0.5f);
        break;
      case 4:
        r = (int) (t * 255.0f + 0.5f);
        g = (int) (p * 255.0f + 0.5f);
        b = (int) (brightness * 255.0f + 0.5f);
        break;
      case 5:
        r = (int) (brightness * 255.0f + 0.5f);
        g = (int) (p * 255.0f + 0.5f);
        b = (int) (q * 255.0f + 0.5f);
        break;
    }
  }
  struct rgb rgb;
  rgb.r = r;
  rgb.g = g;
  rgb.b = b;
  return rgb;
}

