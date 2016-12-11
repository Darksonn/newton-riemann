#!/bin/sh

readonly USAGE_FMT="usage: %s function file-pattern frame-start frame-end

  function:     The function to make a Newton fractal of. Use t for frame number.
  file-pattern: A printf-style pattern for the filenames of the frames.
  frame-start:  The index of the first frame, and the first value used for t.
  frame-end:    The index of the last frame, and the last value used for t.

WARNING: This script overwrites func.str!
"

readonly RESUME_FMT="#!/bin/sh

export PREV_DIFF=\"%s\"
export PREV_FRAME_START=\"%s\"

'%s' '%s' '%s' '%s' '%s'
"

if [ "$#" -ne 4 ]; then
  # shellcheck disable=SC2059
  printf "${USAGE_FMT}" "$(basename "$0")" >&2
  exit 1
fi

die() {
  (
    fmt="$1"
    shift
    printf "%s: ${fmt}\\n" "$0" "$@" >&2
  )
  exit 1
}

readonly CALC_SCALE=5
calc() {
  printf 'scale=%d;%s\n' "${CALC_SCALE}" "$*" | bc
}

readonly FUNCTION="$1"
readonly FILE_PATTERN="$2"
readonly FRAME_START="$3"
readonly FRAME_END="$4"

# Compile newton with the specified function.

printf '%s\n' "${FUNCTION}" >func.str

printf 'Compiling newton...\n'

time_start="$(date +%s)"
make newton >/dev/null || die 'could not compile newton'
time_end="$(date +%s)"

printf 'Compiled newton in %d seconds.\n' "$(( time_end - time_start ))"

# Check for resumation.

TIME_START="$(date +%s)"
if [ -n "${PREV_DIFF}" ]; then
  TIME_START="$(( TIME_START - PREV_DIFF ))"
fi
readonly TIME_START

if [ -z "${FIRST_FRAME}" ]; then
  export FIRST_FRAME="${FRAME_START}"
else
  printf 'Resuming from frame %d.\n' "${FRAME_START}"
fi

# Compute each frame.

i="${FRAME_START}"

while true; do
  # shellcheck disable=SC2059
  file="$(printf "${FILE_PATTERN}" "${i}")"

  printf 'Computing frame %d/%d...\n' "${i}" "${FRAME_END}"

  time_start=$(date +%s)
  ./newton "${i}" | sort -n -k2 -k1 | ppm/ppm 3840 2160 | convert - "${file}" || die 'could not compute frame'
  time_end="$(date +%s)"

  if [ "${i}" -ge "${FRAME_END}" ]; then
    break
  fi

  frame_diff="$(( time_end - time_start ))"
  percent="$(calc "100 * (${i} - ${FIRST_FRAME} + 1) / (${FRAME_END} - ${FIRST_FRAME} + 1)")"

  diff_sec="$(( time_end - TIME_START ))"
  diff="$(calc "${diff_sec}/60")"

  total="$(calc "(${diff} / (${i} - ${FIRST_FRAME} + 1)) * (${FRAME_END} - ${FIRST_FRAME} + 1)")"
  remain="$(calc "${total} - ${diff}")"

  printf 'Frame computed. (%.2f%%, used: %.1fm, total: %.1fm, remaining: %.1fm, this frame: %ds)\n' "${percent}" "${diff}" "${total}" "${remain}" "${frame_diff}"

  i="$(( i + 1 ))"

  # shellcheck disable=SC2059
  printf "${RESUME_FMT}" "${diff_sec}" "${FIRST_FRAME}" "$0" "${FUNCTION}" "${FILE_PATTERN}" "${i}" "${FRAME_END}" >resume.sh
  chmod +x resume.sh
done

rm -f resume.sh

num_frames="$(( FRAME_END - FRAME_START + 1 ))"
total="$(calc "(${time_end} - ${TIME_START}) / 60")"

printf 'Computed %d frames in %.1fm.\n' "${num_frames}" "${total}"
