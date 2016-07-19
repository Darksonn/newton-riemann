#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/complex.h>

#include "gpu.h"
#include "dual.cu"
#include "color.h"

// change the precision of the newton iterations by changing the f typedef
// long double probably wont compile if the function isn't a rational function
typedef double f;
typedef thrust::complex<f> complex;

struct newton_iteration {
  const unsigned int iter;

  newton_iteration(unsigned int _iter) : iter(_iter) {}

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
    struct hsb hsb;
    hsb.h = thrust::arg(z_) / (2*M_PI);
    hsb.s = 1 / (1 + thrust::abs(z_));
    hsb.b = 1;
    struct rgb rgb = HSBtoRGB(hsb);
    return rgb;
  }
};

void newton_fast(unsigned int iter, int len,
    thrust::counting_iterator<unsigned int>& X, thrust::device_vector<struct rgb>& Y) {
  thrust::transform(X, X + len, Y.begin(), newton_iteration(iter));
}

