# newton-riemann

Tool for creating 360° videos of [Newton fractals][1].

Example output of the tool can be found on [my youtube channel][2].

## Usage
The tool can be used with the Makefiles directly, or can be run with the script
`newton-frame.sh`.

Use makefiles if you wish to create a single frame, and the script if you wish
to create many frames.
### Usage with makefiles

Edit the file `func.str` to contain the mathematical function you wish to create
a Newton fractal for.  It supports standard mathematical ascii-notation, some
examples are:

    sin(x)
    x^5-x-1
    exp(2*x) - 1

After you have created the `func.str` file, just run `make`, which will create a
4K image file called `img.png`.  If you wish to create an `mp4` which can be
uploaded to youtube in order to view the image in 360°, call
`make spherical-video.mp4`.

### Usage with script
The script `newton-frame.sh` is used to create many frames, which can be used to
create animated videos.  The usage of the script can be found by running
the script without parameters, and is shown below:

    Usage: ./newton-frame.sh function file-pattern frame-start frame-end

      function:     The function to make a newton fractal of. Use t for frame number.
      file-pattern: A printf style pattern for the filenames of the frames.
      frame-start:  The index of the first frame, and the first value used for t.
      frame-end:    The index of the last frame, and the last value used for t.

The command to produce [this video][3] is shown below. Note that the video uses
a different iteration count than standard.

    ./newton-frame.sh 'exp(x)-t/10' frames/frame%02d.png 1 10

If the computations gets interrupted, you can continue from the last frame by
running the `resume.sh` script.

## Changing the iteration count
The amount of iterations of Newton's method performed on each pixel can be
changed in the file `newton.cu`, and is found in the macro `NEWTON_ITERS`.

  [1]: https://en.wikipedia.org/wiki/Newton_fractal
  [2]: https://www.youtube.com/channel/UCevZjdeIxCKNwaZNEf1BD1A
  [3]: https://youtu.be/zSwQ9eo_6F0

