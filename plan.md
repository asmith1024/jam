# JAM "Julia and Mandelbrot" plan

## Purpose

Create a web page that provides an interactive illustration of the relationship between the Mandelbrot
and Julia sets.

The Mandelbrot set is essentially a map of all possible Julia sets, indicating whether the Julia set
corresponding to a point on the Mandelbrot set is connected or disconnected. It does not however show
what each Julia set looks like.

### References

<https://en.wikipedia.org/wiki/Julia_set>
<https://en.wikipedia.org/wiki/Mandelbrot_set>
<https://en.wikipedia.org/wiki/Plotting_algorithms_for_the_Mandelbrot_set>

### UI basics

00. The UI will be a web page. HTML and client-side javascript.
01. Present two images, oriented left to right on wide screens, top to bottom on narrow screens.
    1.1 Layout is determined by aspect ratio: wider-than-tall → side by side; taller-than-wide → stacked.
02. One image is the Mandelbrot set, the other is a Julia set.
03. Left click+drag on the Mandelbrot set image causes the corresponding Julia set to render
    in the other image based on the current cursor position.
04. The default Mandelbrot set is rendered from -2..2 on both real and imaginary axes.
05. The default Julia set is 0,0 on the Mandelbrot set, rendered from -2..2 as above.
06. Left click+drag on the Mandelbrot set: as the cursor is dragged, the Julia set updates
    to correspond to the current cursor position on the Mandelbrot set.
    6.1 Preserves the current zoom level of the Julia set.
    6.2 During drag (mouse move), the Julia set reverts to default rendering (B&W, default iterations)
        for responsiveness. On mouse up, re-render at the current enhancement level if enhanced.
07. By default, render both sets in black and white with low iteration count for responsiveness.
    7.1 Default iteration count: 10 (configurable constant in code).
    7.2 Use Web Workers for rendering to keep the UI responsive.
    7.3 Alter pixels as they are calculated, so image development is visible to the user.
08. If the user right-clicks on the Mandelbrot set, suppress the browser context menu and display
    a custom context dialog with the following options:
    8.1 Zoom in 10x. Re-center the image on the current point, zoom in 10x and re-render.
        Preserve the current enhance/unenhance state.
        Also apply the same zoom (center + range change) to the Julia set and re-render it.
    8.2 Zoom out 10x. Re-center the image on the current point, zoom out 10x and re-render.
        Preserve the current enhance/unenhance state.
        Also apply the same zoom (center + range change) to the Julia set and re-render it.
    8.3 Reset. Return to the default view (-2..2 on both axes) and clear any enhanced state
        back to default (black-and-white, default iterations).
    8.4 Enhance. Re-render the current image using Exponential Cyclic Coloring in LCH color space
        with shading, at 1000 iterations (configurable constant in code).
    8.5 Unenhance. Re-render the current image in black-and-white with default iterations.
09. If the user right-clicks on the Julia set, suppress the browser context menu and display
    a custom context dialog with the following options:
    9.1 Zoom in 10x. Re-center the image on the current point, zoom in 10x and re-render.
        Preserve the current enhance/unenhance state.
        Does NOT trigger a Mandelbrot re-render.
    9.2 Zoom out 10x. Re-center the image on the current point, zoom out 10x and re-render.
        Preserve the current enhance/unenhance state.
        Does NOT trigger a Mandelbrot re-render.
    9.3 Reset. Return to the default view (-2..2 on both axes) and clear any enhanced state
        back to default (black-and-white, default iterations).
    9.4 Enhance. Re-render the current image using Exponential Cyclic Coloring in LCH color space
        with shading, at 1000 iterations (configurable constant in code).
    9.5 Unenhance. Re-render the current image in black-and-white with default iterations.
    9.6 Center Mandelbrot here. Re-center the Mandelbrot set on the c-value that generated
        this Julia set, preserving all Mandelbrot zoom/enhance properties.

### Rendering

- Color scheme (Enhance mode): Exponential Cyclic Coloring in LCH color space with shading.
  Black-and-white for default/low-res mode.
- Default iterations: 10 (constant `DEFAULT_ITERATIONS`).
- Enhanced iterations: 1000 (constant `ENHANCED_ITERATIONS`).
- All "configurable" values are constants in the code. Clever users can change these themselves.

### Layout

- Each canvas fills 80% of its allocated half of the viewport.
- Layout orientation is responsive based on viewport aspect ratio:
  wider-than-tall → side by side; taller-than-wide → stacked vertically.

### Architecture

- Use Web Workers for fractal computation to keep the main thread responsive.
- Progressive rendering: push pixel data back to the main thread row by row.
- On window resize: re-render both canvases.

Notes:

- Provide a `Reorient` button or other UI cue to swap which image comes first
  (does not change layout direction, only image order).
