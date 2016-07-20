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
STARTTIME=$(date +%s.%N)
printf 'compiling ./newton\n'
make ./newton > /dev/null
ENDTIME=$(date +%s.%N)
printf '%scompiled ./newton in %.01f seconds' "$(tput cuu1)" "$(echo "$ENDTIME - $STARTTIME" | bc -l)"

STARTTIME=$(date +%s.%N)

if [ -n "$PREVDIFF" ]; then
  STARTTIME=$(echo "$STARTTIME - $PREVDIFF" | bc -l)
fi
FRAMESTARTREAL="$FRAMESTART"
if [ -n "$PREVFRAMESTART" ]; then
  FRAMESTARTREAL="$PREVFRAMESTART"
  printf '. Resuming from frame %s\n' "$FRAMESTART"
else
  printf '. Computing first frame.\n'
fi


for ((i="$FRAMESTART";i<="$FRAMEEND";i++)); do
  FILE="$(printf "$FILEPATTERN" $i)"
  FRAMESTARTTIME=$(date +%s.%N)
  ./newton $i | sort -n -k2 -k1 | ./rgb-to-ppm/ppm 3840 2160 | convert - "$FILE"
  ENDTIME=$(date +%s.%N)
  FRAMEDIFF=$(echo "$ENDTIME-$FRAMESTARTTIME" | bc -l)
  PERCENT=$(echo "100*($i - $FRAMESTARTREAL + 1) / ($FRAMEEND - $FRAMESTARTREAL + 1)" | bc -l)
  DIFFSEC=$(echo "$ENDTIME - $STARTTIME" | bc -l)
  DIFF=$(echo "($DIFFSEC)/60" | bc -l)
  TOTAL=$(echo "($DIFF / ($i-$FRAMESTARTREAL+1)) * ($FRAMEEND-$FRAMESTARTREAL+1)" | bc -l)
  REMAIN=$(echo "$TOTAL - $DIFF" | bc -l)
  Ni=$((i+1))
  printf '%scompleted frame %d/%d (%.02f%%) (used: %.01fm, total: %.01fm, remaining: %.01fm, this frame: %.01fs) \n' "$(tput cuu1)" $i "$FRAMEEND" "$PERCENT" "$DIFF" "$TOTAL" "$REMAIN" "$FRAMEDIFF"
  printf '#!/bin/bash\nexport PREVDIFF="%s"\nexport PREVFRAMESTART="%s"\n%s "%s" "%s" "%s" "%s"\nunset PREVDIFF\nunset PREVFRAMESTART\n' "$DIFFSEC" "$FRAMESTARTREAL" "$0" "$FUNCTION" "$FILEPATTERN" "$Ni" "$FRAMEEND" > ./resume.sh
  chmod +x ./resume.sh
done

rm -f ./resume.sh

