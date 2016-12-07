PYTHON ?= python2.7
NVCC ?= nvcc
FFMPEG ?= ffmpeg

NVFLAGS ?= -O2 -std=c++11 -rdc=true

img.png: newton ppm/ppm
	./newton | sort -n -k2 -k1 | ppm/ppm 3840 2160 | convert - img.png

spherical-video.mp4: flat-video.mp4 spatial-media
	$(PYTHON) spatial-media/spatialmedia/__main__.py -i flat-video.mp4 spherical-video.mp4

flat-video.mp4: img.png
	rm -f flat-video.mp4
	$(FFMPEG) -r 1 -loop 1 -i img.png -c:v libx264 -t 30 -pix_fmt yuv420p flat-video.mp4

src/func.cu: func.str genfunc/genfunc
	genfunc/genfunc "$$(cat func.str)" > src/func.cu

genfunc/genfunc: genfunc/Makefile genfunc/genfunc.c
	cd genfunc; $(MAKE)

ppm/ppm: ppm/Makefile ppm/ppm.c
	cd ppm; $(MAKE)

spatial-media:
	git clone --depth=1 https://github.com/google/spatial-media spatial-media

newton: src/newton.cu src/gpu.cu src/gpu.h src/func.cu src/color.cu src/color.h
	$(NVCC) $(NVFLAGS) -lm -o $@ src/color.cu src/newton.cu src/gpu.cu
