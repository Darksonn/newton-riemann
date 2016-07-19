#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include <complex.h>

#include "func.h"

int main(int argc, char **argv) {
  if (argc != 2) return 1;
  char *f = func_parse(argv[1], strlen(argv[1]));
  printf("%s\n", f);
  return 0;
}

