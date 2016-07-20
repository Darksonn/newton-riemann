#!/bin/bash
if [ "$#" -ne 4 ]; then
  printf 'Usage: %s function file-pattern frame-start frame-end\n\n' "$0"
  printf '  function:     The function to make a newton fractal of. Use t for frame number.\n'
  printf '  file-pattern: A printf style pattern for the filenames of the frames.\n'
  printf '  frame-start:  The index of the first frame, and the first value used for t.\n'
  printf '  frame-end:    The index of the last frame, and the last value used for t.\n\n'
  exit 1
fi

FUNCTION="$1"
FILEPATTERN="$2"
FRAMESTART="$3"
FRAMEEND="$4"

printf '%s' "$FUNCTION" > func.str
make ./newton

STARTTIME=$(date +%s.%N)

for ((i="$FRAMESTART";i<="$FRAMEEND";i++)); do
  FILE="$(printf "$FILEPATTERN" $i)"
  ./newton $i | sort -n -k2 -k1 | ./rgb-to-ppm/ppm 3840 2160 | convert - "$FILE"
  ENDTIME=$(date +%s.%N)
  PERCENT=$(echo "100*($i - $FRAMESTART + 1) / ($FRAMEEND - $FRAMESTART + 1)" | bc -l)
  DIFF=$(echo "($ENDTIME - $STARTTIME)/60" | bc -l)
  TOTAL=$(echo "($DIFF / ($i-$FRAMESTART+1)) * ($FRAMEEND-$FRAMESTART+1)" | bc -l)
  REMAIN=$(echo "$TOTAL - $DIFF" | bc -l)
  printf 'completed frame %d/%d (%.02f%%) (used: %.01fm, total: %.01fm, remaining: %.01fm)\n' $i "$FRAMEEND" "$PERCENT" "$DIFF" "$TOTAL" "$REMAIN"
done


