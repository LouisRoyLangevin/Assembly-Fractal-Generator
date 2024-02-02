# Assembly-Fractal-Generator
MIPS assembly program that allows the user to generate custom fractals

## What features are available
You can draw the Julia set of any parameters (a,b) (https://en.wikipedia.org/wiki/Julia_set#Quadratic_polynomials).

You can draw the boundary of any Julia set.

You can draw the Mandelbrot set (https://en.wikipedia.org/wiki/Mandelbrot_set).


## How to use the features
You can download the "Fractal generator.asm" file and the indications are at the beginning of the .text section.


## How it works
### Julia set
For each pixel (representing point a+bi in the complex plane) and some parameters p and q, the program verifies how many times we need to apply the function f(x,y) = (x^2 - y^2 + p, 2xy + q) on (a,b) before the norm exceeds some predetermined threshold T.  If after applying f 10 times, we still haven't reached T, then pixel color will be black, if it takes 9 times, 8 times dark blue, 7 times then blue, 6 times light blue, 5 times dark green, etc.

### Mandelbrot set
For each pixel (representing point a+bi in the complex plane), we look at the color of the point (0,0) in the Julia set with parameters a and b and we assign it this color.

More info can be found here: https://math.libretexts.org/Bookshelves/Analysis/Complex_Analysis_-_A_Visual_and_Interactive_Introduction_(Ponce_Campuzano)/05%3A_Chapter_5/5.06%3A_The_Julia_Set

### Boundary of Julia set
We give the function a starting point (x0,y0) and it will repeatedly apply the relation f(x,y) = sqrt(x + yi - (a + bi)) on it, chosing randomly the among the possible complex square roots.  At each step, it colors the associated pixel in yellow.
