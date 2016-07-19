# newton-riemann

Tool for creating 360° videos of [newton fractals][1].

Example output of the tool can be found on [my youtube channel][2].

## Usage
The tool can be used with the Makefiles directly, or can be run with the script
`newton-frame.sh`.
### Usage with makefiles

Edit the file `func.str` to contain the mathematical function you wish to create
a newton fractal for.  It supports standard mathematical ascii-notation, some
examples are:

    sin(x)
    x^5-x-1
    exp(2*x) - 1

After you have created the `func.str` file, just run `make`, which will create a
4K image file called `img.png`.  If you wish to create an `mp4` which can be
uploaded to youtube in order to view the image in 360°, call
`make spherical-video.mp4`.

### Usage with script
TODO



  [1]: https://en.wikipedia.org/wiki/Newton_fractal
  [2]: https://www.youtube.com/channel/UCevZjdeIxCKNwaZNEf1BD1A

