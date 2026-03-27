# JAM — Julia and Mandelbrot

An interactive web application that illustrates the relationship between the Mandelbrot set and Julia sets. Drag across the Mandelbrot set to explore the corresponding Julia sets in real time.

Developed by Claude Opus 4.6 via Kiro IDE.

## Features

- Side-by-side Mandelbrot and Julia set rendering with responsive layout
- Left click+drag on the Mandelbrot set to generate Julia sets interactively
- Right-click context menus on both canvases: zoom in/out 10×, reset, enhance, unenhance
- Enhance mode uses Exponential Cyclic Coloring in LCH color space with shading (1000 iterations)
- Default mode renders in black and white at 10 iterations for responsiveness
- Web Workers for off-thread fractal computation with progressive row-by-row rendering
- Reorient button to swap image order

## Running locally

Web Workers require HTTP — opening `index.html` directly via `file://` won't work. Use any local server:

**Python:**

```cli
python -m http.server 8000
```

**Node (npx):**

```cli
npx serve .
```

Then open `http://localhost:8000` in your browser.

## Files

- `index.html` — page structure
- `style.css` — layout and styling
- `app.js` — main thread logic (canvas management, events, context menus, worker coordination)
- `worker.js` — Web Worker for Mandelbrot/Julia computation and coloring
- `plan.md` — design document
