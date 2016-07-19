
img.png: newton ./rgb-to-ppm/ppm
	./newton | sort -n -k2 -k1 | ./rgb-to-ppm/ppm 3840 2160 | convert - img.png

spherical-video.mp4: flat-video.mp4 spatial-media
	python2.7 ./spatial-media/spatialmedia/__main__.py -i flat-video.mp4 spherical-video.mp4
flat-video.mp4: img.png
	rm -f flat-video.mp4
	ffmpeg -r 1 -loop 1 -i img.png -c:v libx264 -t 30 -pix_fmt yuv420p flat-video.mp4

newton: newton.cu gpu.cu gpu.h func.cu
	nvcc color.cu newton.cu gpu.cu -rdc=true -std=c++11 -O2 -lm -o newton
func.cu: func.str C-gen/eval
	C-gen/eval "$$(cat ./func.str)" > func.cu
C-gen/eval: C-gen/eval.c C-gen/func.c C-gen/func.h C-gen/Makefile
	cd C-gen; make eval
./rgb-to-ppm/ppm: ./rgb-to-ppm/ppm.c ./rgb-to-ppm/Makefile
	cd rgb-to-ppm; make ppm

spatial-media:
	git clone --depth=1 https://github.com/google/spatial-media spatial-media

