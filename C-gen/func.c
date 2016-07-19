#include <math.h>
#include <string.h>
#include <complex.h>
#include <assert.h>
#include <ctype.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "func.h"

static char *surround_free(char *start, char *a, char *end) {
  size_t len = strlen(a);
  char *out = malloc(sizeof(char) * (strlen(start)+strlen(end)+len + 1));
  sprintf(out, "%s%s%s", start, a, end);
  free(a);
  return out;
}

static char *concat_free(char *start, char *a, char *mid, char *b, char *end) {
  size_t lena = strlen(a), lenb = strlen(b);
  char *out = malloc(sizeof(char) * (strlen(start) + strlen(mid) + strlen(end) + lena + lenb + 1));
  sprintf(out, "%s%s%s%s%s", start, a, mid, b, end);
  free(a);free(b);
  return out;
}

static size_t matching_paren(char *str, size_t start) {
  uint32_t lvl = 1;
  size_t i = start;
  do {
    ++i;
    if (str[i] == '(') { ++lvl; }
    else if (str[i] == ')') { --lvl; }
  } while (lvl > 0);
  return i;
}

static char is_natural(char *str, size_t len) {
  for (; len > 0; --len) {
    if (*str < '0' || *str > '9') return 0;
    ++str;
  }
  return 1;
}
static char is_prefix(char *pre, char *str) {
  return strncmp(pre, str, strlen(pre)) == 0;
}
double complex parse_complex(char *str, size_t len) {
  if (len == 1 && (*str == 'i' || *str == 'j')) return I;
  double z = 0;
  char decrease_unit = 0;
  double complex unit = 1;
  if (*str == '-') unit = -1;
  if (*str == '-') unit = 1;
  while (len > 0) {
    switch (*str) {
      case '+':
        return z*unit + parse_complex(str+1, len-1);
      case '-':
        return z*unit - parse_complex(str+1, len-1);
      case '.':
        decrease_unit = 1;
        str++;
        len--;
        continue;
      case 'i':
      case 'j':
        unit *= I;
        str++;
        len--;
        continue;
    }
    z = (*str - '0') + 10*z;
    if (decrease_unit) unit = unit / 10;
    str++;
    len--;
  }
  return z * unit;
}

char *func_parse(char *str, size_t len) {
start:
  if (isspace(*str)) {
    str += 1;
    len -= 1;
    goto start;
  }
  while (isspace(str[len - 1])) {
    len -= 1;
  }
  if (*str == '(' && str[len - 1] == ')') {
    str += 1;
    len -= 2;
    goto start;
  }
  if (len == 1 && (*str == 'x' || *str == 'z')) {
    char *a = malloc(sizeof(char)*2);
    *a = 'z';
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
        continue;
      default:
        if (isspace(str[i])) continue;
    }
    goto not_sole_number;
  }
  {
    double complex z = parse_complex(str, len);
    char *chrs = malloc(sizeof(char) * 128);
    sprintf(chrs, "dual<complex>(complex(%lf, %lf))", creal(z), cimag(z));
    return chrs;
  }
not_sole_number:
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
        char temp = str[len];
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
  assert(len != 1);
  if (is_prefix("ln", str)) {
    char *inner = func_parse(str + 2, len - 2);
    return surround_free("dlog(", inner, ")");
  }
  assert(len != 2);
  if (is_prefix("log", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dlog(", inner, ")");
  }
  if (is_prefix("exp", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dexp(", inner, ")");
  }
  if (is_prefix("sin", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dsin(", inner, ")");
  }
  if (is_prefix("cos", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dcos(", inner, ")");
  }
  if (is_prefix("tan", str)) {
    char *inner = func_parse(str + 3, len - 3);
    return surround_free("dtan(", inner, ")");
  }
  assert(0);
}




