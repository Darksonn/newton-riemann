
#ifndef _GPU_H
#define _GPU_H

#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#define IMGW 3840
#define IMGH 2160

void newton_fast(unsigned int iter, int len,
    thrust::counting_iterator<unsigned int>& X, thrust::device_vector<struct rgb>& Y);

#endif // _GPU_H

