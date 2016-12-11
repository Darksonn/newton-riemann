# Newton–Riemann

Tool for creating 360° videos of [Newton fractals][1].

Example output of the tool can be found on [my YouTube channel][2].

I don't know if it compiles on anything but linux.


## Dependencies

The version numbers are just the version I have, it might work with earlier or later versions.

An NVIDIA GPU is required to run the code.

* CUDA 7.5.18-4. For the code in `src/`.
* GCC 6.1.1 (also tested with version 5.4.0). For the code in `genfunc/` and `ppm/`.
* FFmpeg 3.0.2. For creating video files from the frames.
* ImageMagick 6.9.5-2. For creating PNG files from the frames.
* Python 2.7.12. For embedding 360° metadata in the video files.


## Usage

The tool can be used with the `Makefile` directly, or can be run with the script `newton-frame.sh`.

Use `make` if you wish to create a single frame, and the script if you wish to create many frames.


### Usage with `make`

Edit the file `func.str` to contain the mathematical function you wish to create a Newton fractal for. It supports standard mathematical ASCII-notation, some examples are:

    sin(x)
    x^5 - x - 1
    exp(2*x) - 1

After you have created the `func.str` file, just run `make`, which will create a 4K image file called `img.png`. If you wish to create an MP4 360° video file that can be uploaded to YouTube, call `make spherical-video.mp4`.


### Usage with script

The script `newton-frame.sh` is used to create many frames, which can be used to create animated videos. The usage of the script can be found by running the script without parameters, and is shown below:

    Usage: ./newton-frame.sh function file-pattern frame-start frame-end

      function:     The function to make a newton fractal of. Use t for frame number.
      file-pattern: A printf style pattern for the filenames of the frames.
      frame-start:  The index of the first frame, and the first value used for t.
      frame-end:    The index of the last frame, and the last value used for t.

The command to produce [this video][3] is shown below.

    ./newton-frame.sh 'exp(x) + (t+1)*0.005' out/frame%03d.png 0 999

If the computations gets interrupted, you can resume from the last frame by running the `resume.sh` script.


## Changing the iteration count

The number of iterations of Newton's method performed on each pixel can be changed in the file `newton.cu`, defined by the macro `NEWTON_ITERS`.


[1]: https://en.wikipedia.org/wiki/Newton_fractal
[2]: https://www.youtube.com/channel/UCevZjdeIxCKNwaZNEf1BD1A
[3]: https://youtu.be/ErmEzYHugm8
