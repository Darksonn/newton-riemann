#include <assert.h>
#include <complex.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *argv0 = "genfunc";

static void die(const char *fmt, ...) {
  fprintf(stderr, "%s: ", argv0);

  va_list ap;

  va_start(ap, fmt);
  vfprintf(stderr, fmt, ap);
  va_end(ap);

  if (fmt[strlen(fmt) - 1] == ':') {
    fputc(' ', stderr);
    perror(NULL);
  }

  exit(EXIT_FAILURE);
}

static void usage(void) {
  const char *progname = argv0;

  const char *basename = strrchr(progname, '/');
  if (basename) {
    progname = basename + 1;
  }

  fprintf(stderr, "usage: %s function\n", progname);
  exit(EXIT_FAILURE);
}

// TODO: The following functions can overflow, though that requires the
// arguments to be very large in the first place.

static char *surround_free(const char *start, char *a, const char *end) {
  size_t len = strlen(start) + strlen(a) + strlen(end) + 1;
  char *out = malloc(sizeof(char) * len);

  if (sprintf(out, "%s%s%s", start, a, end) < 0) {
    die("sprintf failed:");
  }

  free(a);
  return out;
}

static char *concat_free(const char *start, char *a, const char *mid, char *b, const char *end) {
  size_t len = strlen(start) + strlen(a) + strlen(mid) + strlen(b) + strlen(end) + 1;
  char *out = malloc(sizeof(char) * len);

  if (sprintf(out, "%s%s%s%s%s", start, a, mid, b, end) < 0) {
    die("sprintf failed:");
  }

  free(a);
  free(b);
  return out;
}

static size_t matching_paren(const char *str, size_t start) {
  uint32_t lvl = 1;
  size_t i = start;
  do {
    ++i;
    if (str[i] == '(') { ++lvl; }
    else if (str[i] == ')') { --lvl; }
  } while (lvl > 0);
  return i;
}

static int is_space(char ch) {
  switch (ch) {
  case ' ':
  case '\t':
  case '\r':
  case '\n':
    return 1;
  default:
    return 0;
  }
}

static int is_natural(char *str, size_t len) {
  for (; len > 0; --len) {
    if (*str < '0' || *str > '9') return 0;
    ++str;
  }
  return 1;
}

static int has_prefix(char *pre, char *str) {
  return strncmp(pre, str, strlen(pre)) == 0;
}

static double complex parse_complex(char *str, size_t len) {
  double complex sum = 0;
  double complex unit = 1;

  double z;
  int has_point, has_numeral;

retry:
  z = 1;
  has_point = 0;
  has_numeral = 0;

  while (len > 0 && *str == '-') {
    unit = -unit;
    str++;
    len--;
  }

  if (len <= 0) {
    die("expected complex literal\n");
  }

  while (len > 0) {
    char ch = *str;

    str++;
    len--;

    switch (ch) {
    case '+':
      sum += z * unit;
      unit = 1;
      goto retry;

    case '-':
      sum += z * unit;
      unit = -1;
      goto retry;

    case '.':
      if (has_point) {
        die("unexpected second decimal point in literal\n");
      }
      has_point = 1;
      break;

    case 'i':
    case 'j':
      unit *= I;
      break;

    default:
      if (ch < '0' || '9' < ch) {
        die("unexpected character '%c' in complex literal\n", ch);
      }
      if (!has_numeral) {
        has_numeral = 1;
        z = 0;
      }
      z = (ch - '0') + 10*z;
      if (has_point) { unit /= 10; }
    }
  }

  if (has_point && !has_numeral) {
    die("expected digit either before or after '.'\n");
  }

  return sum + z * unit;
}

static char *func_parse(char *str, size_t len) {
start:
  while (is_space(*str)) {
    str += 1;
    len -= 1;
  }
  while (is_space(str[len - 1])) {
    len -= 1;
  }
  if (len > 0 && *str == '(' && str[len - 1] == ')') {
    str += 1;
    len -= 2;
    goto start;
  }
  if (len == 1 && (*str == 'x' || *str == 'z')) {
    char *a = malloc(sizeof(char) * 2);
    a[0] = 'z';
    a[1] = 0;
    return a;
  }
  if (len == 1 && *str == 't') {
    char *a = malloc(sizeof(char) * 2);
    a[0] = 't';
    a[1] = 0;
    return a;
  }
  size_t i;
  for (i = 0; i < len; ++i) {
    switch (str[i]) {
    case '+':
    case '-':
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '.':
    case 'i':
    case 'j':
      break;
    default:
      goto not_literal;
    }
  }
  {
    double complex z = parse_complex(str, len);
    char *chrs = malloc(sizeof(char) * 128);
    sprintf(chrs, "dual<complex>(complex(%lf, %lf))", creal(z), cimag(z));
    return chrs;
  }

not_literal:
  for (i = 0; i < len; ++i) {
    if (str[i] == '+') {
      char *a = func_parse(str, i);
      char *b = func_parse(str + (i + 1), len - i - 1);
      return concat_free("(", a, ") + (", b, ")");
    }
    if (str[i] == '(') {
      i = matching_paren(str, i);
    }
  }
  ssize_t minus = -1;
  for (i = 0; i < len; ++i) {
    if (str[i] == '-') {
      minus = i;
    }
    if (str[i] == '(') {
      i = matching_paren(str, i);
    }
  }
  if (minus != -1) {
    i = minus;
    char *a = func_parse(str, i);
    char *b = func_parse(str + (i + 1), len - i - 1);
    return concat_free("(", a, ") - (", b, ")");
  }
  for (i = 0; i < len; ++i) {
    if (str[i] == '*') {
      char *a = func_parse(str, i);
      char *b = func_parse(str + (i + 1), len - i - 1);
      return concat_free("(", a, ") * (", b, ")");
    }
    if (str[i] == '(') {
      i = matching_paren(str, i);
    }
  }
  for (i = 0; i < len; ++i) {
    if (str[i] == '/') {
      char *a = func_parse(str, i);
      char *b = func_parse(str + (i + 1), len - i - 1);
      return concat_free("(", a, ") / (", b, ")");
    }
    if (str[i] == '(') {
      i = matching_paren(str, i);
    }
  }
  for (i = 0; i < len; ++i) {
    if (str[i] == '^') {
      char *a = func_parse(str, i);
      i += 1;
      str = str + i;
      len = len - i;
      if (is_natural(str, len)) {
        // char temp = str[len];
        str[len] = 0;
        char *b = malloc(sizeof(char) * (strlen(str) + 6));
        sprintf(b, "), %s)", str);
        char *r = surround_free("dpown((", a, b);
        free(b);
        return r;
      } else {
        char *b = func_parse(str, i);
        return concat_free("dpow((", a, "), (", b, "))");
      }
    }
    if (str[i] == '(') {
      i = matching_paren(str, i);
    }
  }

  if (has_prefix("ln", str)) {
    char *inner = func_parse(str + 2, len - 2);
    return surround_free("dlog(", inner, ")");
  }

  if (has_prefix("log", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dlog(", inner, ")");
  }
  if (has_prefix("exp", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dexp(", inner, ")");
  }
  if (has_prefix("sin", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dsin(", inner, ")");
  }
  if (has_prefix("cos", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dcos(", inner, ")");
  }
  if (has_prefix("tan", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dtan(", inner, ")");
  }

  die("unrecognized function: '%s'\n", str);
  return NULL;
}

int main(int argc, char **argv) {
  if (argv[0]) {
    argv0 = argv[0];
  }

  if (argc != 2) {
    usage();
  }

  char *f = func_parse(argv[1], strlen(argv[1]));
  printf("%s\n", f);
  return 0;
}
