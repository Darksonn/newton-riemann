#include <inttypes.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *argv0 = "ppm";

static void die(const char *fmt, ...) {
  fprintf(stderr, "%s: ", argv0);

  va_list ap;

  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
  exit(EXIT_FAILURE);
}

static void usage(void) {
  const char *progname = argv0;

  const char *basename = strrchr(progname, '/');
  if (basename) {
    progname = basename + 1;
  }

  fprintf(stderr, "usage: %s width height\n", progname);
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
  if (argv[0]) {
    argv0 = argv[0];
  }

  if (argc != 3) {
    usage();
  }

  uint32_t width, height;

  if (sscanf(argv[1], "%" SCNu32, &width) != 1) {
    die("invalid width\n");
  }
  if (sscanf(argv[2], "%" SCNu32, &height) != 1) {
    die("invalid height\n");
  }

  uint32_t num_pixels = width * height;

  printf("P3\n%" PRIu32 " %" PRIu32 "\n256\n", width, height);

  for (uint32_t i = 0; i < num_pixels; i++) {
    uint32_t x, y;
    uint8_t r, g, b;

    if (scanf(" %" SCNu32 " %" SCNu32 " %" SCNu8 " %" SCNu8 " %" SCNu8, &x, &y, &r, &g, &b) != 5) {
      die("could not read pixel %" PRIu32 " of %" PRIu32 "\n", i, num_pixels);
    }

    printf("%" PRIu8 " %" PRIu8 " %" PRIu8 "\n", r, g, b);
  }

  return EXIT_SUCCESS;
}
