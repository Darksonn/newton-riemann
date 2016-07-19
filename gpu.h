
#ifndef _GPU_H
#define _GPU_H

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/complex.h>
#define IMGW 3840
#define IMGH 2160

// change the precision of the newton iterations by changing the f typedef
// long double probably wont compile if the function isn't a rational function
typedef double f;
#define PRIf "lf"

void newton_fast(unsigned int iter, thrust::complex<f> t, int len,
    thrust::counting_iterator<unsigned int>& X, thrust::device_vector<struct rgb>& Y);

#endif // _GPU_H

