#!/bin/bash

echo "$1" > func.str
make ./newton > /dev/null 2>&1
./newton | sort -n -k2 -k1 | ./rgb-to-ppm/ppm 3840 2160 | convert - "$2" &

