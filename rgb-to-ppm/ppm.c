#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <assert.h>
#include <math.h>
#include <string.h>
#include <complex.h>

int main(int argc, char **argv) {

  if (argc != 3) return 1;

  uint32_t a1, a2;
  uint8_t r,g,b;
  uint32_t width, height;

  sscanf(argv[1], "%u", &width);
  sscanf(argv[2], "%u", &height);
  uint32_t i = 0;

  printf("P3\n%u %u\n256\n", width, height);
  while (scanf(" %u %u %" SCNu8 " %" SCNu8 " %" SCNu8, &a1, &a2, &r, &g, &b) != EOF) {
    if (i++ != a1 + a2*width) {
      fprintf(stderr, "wrong pixel order %u (width: %u, height: %u)\n", i, width, height);
      return 1;
    }
    printf("%" PRIu8 " %" PRIu8 " %" PRIu8 "\n", r, g, b);
  }
  return 0;
}

