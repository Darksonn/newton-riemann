#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/complex.h>

#include "gpu.h"
#include "dual.cu"
#include "color.h"

typedef thrust::complex<f> complex;

// increase this value to make the image brighter
#define BRIGHTNESS_EPSILON 0.1

struct newton_iteration {
  const unsigned int iter;
  const dual<complex> t;

  newton_iteration(unsigned int _iter, complex _t) : iter(_iter), t(_t) {}

  __host__ __device__
  struct rgb operator()(const unsigned int& p) const {
    const unsigned int x = p % IMGW;
    const unsigned int y = p / IMGW;
    const f longitude = x * 2 * M_PI / (f) IMGW + M_PI;
    const f latitude  = y * M_PI / (2*(f) IMGH);
    complex z_ = thrust::exp(complex(0, longitude)) *
                 thrust::tan(complex(latitude, 0));
    for (unsigned int i = 0; i < iter; ++i) {
      const dual<complex> z(z_, 1);
      const dual<complex> fz =
#include "func.cu"
        ;
      z_ = z_ - fz.a / fz.b;
    }
    struct hsl hsl(thrust::arg(z_) / (2*M_PI), 1, 1 - 1 / (1 + thrust::abs(z_) * BRIGHTNESS_EPSILON));
    struct rgb rgb = HSLtoRGB(hsl);
    return rgb;
  }
};

void newton_fast(unsigned int iter, complex t, int len,
    thrust::counting_iterator<unsigned int>& X, thrust::device_vector<struct rgb>& Y) {
  thrust::transform(X, X + len, Y.begin(), newton_iteration(iter, t));
}

