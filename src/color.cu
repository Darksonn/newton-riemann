
#include "color.h"

__host__ __device__
inline bool is_weird(float f) {
  return isnan(f) || isinf(f);
}

__host__ __device__
struct rgb HSVtoRGB(struct hsv hsv) {
  struct rgb black;
  black.r = black.g = black.b = 0;
  if (is_weird(hsv.h) || is_weird(hsv.s) || is_weird(hsv.v)) return black;
  uint8_t r,g,b;
  float hue = hsv.h;
  float saturation = hsv.s;
  float brightness = hsv.v;
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
__host__ __device__
static float hue2rgb(float p, float q, float t) {
  if(t < 0) t += 1;
  if(t > 1) t -= 1;
  if(t < 1./6.) return p + (q - p) * 6 * t;
  if(t < 1./2.) return q;
  if(t < 2./3.) return p + (q - p) * (2./3. - t) * 6;
  return p;
}
__host__ __device__
struct rgb HSLtoRGB(struct hsl hsl) {
  float r, g, b;
  float h = hsl.h, s = hsl.s, l = hsl.l;

  if(s == 0){
    r = g = b = l; // achromatic
  }else{
    float q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    float p = 2 * l - q;
    r = hue2rgb(p, q, h + 1./3.);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1./3.);
  }

  struct rgb rgb;
  rgb.r = uint8_t(r * 255);
  rgb.g = uint8_t(g * 255);
  rgb.b = uint8_t(b * 255);
  return rgb;
}

