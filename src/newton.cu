#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include "gpu.h"
#include "color.h"

#define LOOP_COUNT 30000
#define GPU_ARRAYS 16
#define NEWTON_ITERS 2048

inline size_t len_from(unsigned int pixel_one) {
  unsigned int remaining = IMGW*IMGH - pixel_one;
  if (remaining > LOOP_COUNT) return LOOP_COUNT;
  return remaining;
}

void write_data(thrust::host_vector<struct rgb>& H, size_t len, unsigned int pixel_one) {
  for (size_t i = 0; i < len; ++i) {
    const unsigned int p = pixel_one + i;
    const unsigned int x = p % IMGW;
    const unsigned int y = p / IMGW;
    struct rgb c = H[i];
    printf("%u %u %d %d %d\n", x, y, (int) c.r, (int) c.g, (int) c.b);
  }
}

// the following three functions parse the time command-line parameter to a
// complex using recursive descent
f parse_float(char **str) {
  char *p = *str;
  bool exp_last = false;
  while (isdigit(*p) || *p == '.' || *p == 'e' || *p == 'E') {
loop_again:
    exp_last = *p == 'e' || *p == 'E';
    ++p;
  }
  if (exp_last && (*p == '-' || *p == '+')) goto loop_again;
  char c = *p;
  *p = 0;
  f res;
  sscanf(*str, "%" PRIf, &res);
  *p = c;
  *str = p;
  return res;
}
thrust::complex<f> parse_term(char **str) {
  thrust::complex<f> unit(1), i(0, 1);
  while (**str == 'i' || **str == 'j') {
    (*str)++;
    unit *= i;
  }
  f abs(parse_float(str));
  while (**str == 'i' || **str == 'j') {
    (*str)++;
    unit *= i;
  }
  return thrust::complex<f>(abs) * unit;
}
thrust::complex<f> parse_complex(char *str) {
  thrust::complex<f> final(0);
  while (*str) {
    thrust::complex<f> unit(1);
    if (*str == '-') unit = -1;
    if (*str == '-' || *str == '+') ++str;
    thrust::complex<f> term(parse_term(&str));
    final += unit * term;
  }
  return final;
}

int main(int argc, char **argv) {

  thrust::complex<f> t(0);
  if (argc > 1) {
    t = parse_complex(argv[1]);
  }

  thrust::device_vector<struct rgb> D[GPU_ARRAYS];
  thrust::host_vector<struct rgb> H(LOOP_COUNT);
  size_t lens[GPU_ARRAYS];
  unsigned int po[GPU_ARRAYS];
  memset(lens, 0, sizeof(size_t) * GPU_ARRAYS);
  for (int i = 0; i < GPU_ARRAYS; ++i) {
    D[i].resize(LOOP_COUNT);
  }

  int gpu = 0;
  uint32_t written = 0;
  unsigned int next_po = 0;
  while (1) {
    if (lens[gpu]) {
      H = D[gpu];
      write_data(H, lens[gpu], po[gpu]);
      written += lens[gpu];
      lens[gpu] = 0;
    }
    size_t len = len_from(next_po);
    if (len == 0) goto print;
    lens[gpu] = len;
    po[gpu] = next_po;
    thrust::counting_iterator<unsigned int> counter(next_po);
    newton_fast(NEWTON_ITERS, t, len, counter, D[gpu]);
    gpu = (gpu + 1) % GPU_ARRAYS;
    next_po += len;
  }
print:
  for (gpu = 0; gpu < GPU_ARRAYS; ++gpu) {
    if (lens[gpu]) {
      H = D[gpu];
      write_data(H, lens[gpu], po[gpu]);
      written += lens[gpu];
      lens[gpu] = 0;
    }
  }

  return 0;
}


