#!/bin/bash

FUNCTION="$1"
FILEPATTERN="$2"
FRAMESTART="$3"
FRAMEEND="$4"

printf '%s' "$FUNCTION" > func.str
make ./newton

for ((i="$FRAMESTART";i<="$FRAMEEND";i++)); do
  FILE="$(printf "$FILEPATTERN" $i)"
  ./newton $i | sort -n -k2 -k1 | ./rgb-to-ppm/ppm 3840 2160 | convert - "$FILE"
  printf 'completed frame %d/%d (%.02f%%)\n' $i "$FRAMEEND" $(lua -e "print(100*($i - $FRAMESTART + 1) / ($FRAMEEND - $FRAMESTART + 1))")
done


