// ============================================================
// Fractal Web Worker — computes Mandelbrot / Julia row-by-row
// ============================================================

const DEFAULT_ITERATIONS = 10;
const ENHANCED_ITERATIONS = 1000;

// --- LCH → sRGB conversion helpers ---

function lchToLab(l, c, h) {
  const hRad = h * Math.PI / 180;
  return [l, c * Math.cos(hRad), c * Math.sin(hRad)];
}

function labToXyz(l, a, b) {
  const fy = (l + 16) / 116;
  const fx = a / 500 + fy;
  const fz = fy - b / 200;
  const xr = fx > 0.206897 ? fx * fx * fx : (fx - 16 / 116) / 7.787;
  const yr = l > 7.9996 ? fy * fy * fy : l / 903.3;
  const zr = fz > 0.206897 ? fz * fz * fz : (fz - 16 / 116) / 7.787;
  // D65 white point
  return [xr * 0.95047, yr * 1.0, zr * 1.08883];
}

function xyzToSrgb(x, y, z) {
  let r =  3.2404542 * x - 1.5371385 * y - 0.4985314 * z;
  let g = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z;
  let b =  0.0556434 * x - 0.2040259 * y + 1.0572252 * z;
  // Gamma
  r = r > 0.0031308 ? 1.055 * Math.pow(r, 1 / 2.4) - 0.055 : 12.92 * r;
  g = g > 0.0031308 ? 1.055 * Math.pow(g, 1 / 2.4) - 0.055 : 12.92 * g;
  b = b > 0.0031308 ? 1.055 * Math.pow(b, 1 / 2.4) - 0.055 : 12.92 * b;
  return [
    Math.max(0, Math.min(255, Math.round(r * 255))),
    Math.max(0, Math.min(255, Math.round(g * 255))),
    Math.max(0, Math.min(255, Math.round(b * 255)))
  ];
}

function lchToRgb(l, c, h) {
  const [labL, labA, labB] = lchToLab(l, c, h);
  const [x, y, z] = labToXyz(labL, labA, labB);
  return xyzToSrgb(x, y, z);
}

// --- Coloring ---

function colorEnhanced(iter, maxIter, zr, zi) {
  if (iter >= maxIter) return [0, 0, 0, 255]; // in set → black

  // Smooth iteration count
  const modulus = Math.sqrt(zr * zr + zi * zi);
  const smooth = iter + 1 - Math.log(Math.log(modulus)) / Math.log(2);

  // Exponential cyclic coloring
  const t = smooth / 20; // cycle speed
  const hue = (t * 360) % 360;
  const chroma = 50 + 30 * Math.sin(t * 2.5);
  // Shading: darken near the set boundary
  const shade = 1 - Math.exp(-smooth * 0.15);
  const lightness = 10 + 70 * shade;

  const [r, g, b] = lchToRgb(lightness, chroma, hue < 0 ? hue + 360 : hue);
  return [r, g, b, 255];
}

function colorBW(iter, maxIter) {
  if (iter >= maxIter) return [0, 0, 0, 255];
  const v = 255;
  return [v, v, v, 255];
}

// --- Fractal iteration ---

function mandelbrotPixel(cx, cy, maxIter) {
  let zr = 0, zi = 0, zr2 = 0, zi2 = 0, iter = 0;
  while (zr2 + zi2 <= 4 && iter < maxIter) {
    zi = 2 * zr * zi + cy;
    zr = zr2 - zi2 + cx;
    zr2 = zr * zr;
    zi2 = zi * zi;
    iter++;
  }
  return { iter, zr, zi };
}

function juliaPixel(zr0, zi0, cr, ci, maxIter) {
  let zr = zr0, zi = zi0, zr2 = zr * zr, zi2 = zi * zi, iter = 0;
  while (zr2 + zi2 <= 4 && iter < maxIter) {
    zi = 2 * zr * zi + ci;
    zr = zr2 - zi2 + cr;
    zr2 = zr * zr;
    zi2 = zi * zi;
    iter++;
  }
  return { iter, zr, zi };
}

// --- Main message handler ---

let currentJobId = null;

self.onmessage = function(e) {
  const msg = e.data;

  if (msg.type === 'cancel') {
    currentJobId = null;
    return;
  }

  if (msg.type === 'render') {
    const { jobId, fractalType, width, height, centerR, centerI, rangeR, rangeI, enhanced, juliaC } = msg;
    currentJobId = jobId;

    const maxIter = enhanced ? ENHANCED_ITERATIONS : DEFAULT_ITERATIONS;
    const colorFn = enhanced ? colorEnhanced : colorBW;

    const minR = centerR - rangeR / 2;
    const minI = centerI - rangeI / 2;
    const pixelW = rangeR / width;
    const pixelH = rangeI / height;

    for (let y = 0; y < height; y++) {
      // Check if this job was cancelled
      if (currentJobId !== jobId) return;

      const rowData = new Uint8ClampedArray(width * 4);
      const ci = minI + y * pixelH;

      for (let x = 0; x < width; x++) {
        const cr = minR + x * pixelW;
        let result;

        if (fractalType === 'mandelbrot') {
          result = mandelbrotPixel(cr, ci, maxIter);
        } else {
          result = juliaPixel(cr, ci, juliaC.r, juliaC.i, maxIter);
        }

        const color = colorFn(result.iter, maxIter, result.zr, result.zi);
        const idx = x * 4;
        rowData[idx]     = color[0];
        rowData[idx + 1] = color[1];
        rowData[idx + 2] = color[2];
        rowData[idx + 3] = color[3];
      }

      self.postMessage({ type: 'row', jobId, y, rowData }, [rowData.buffer]);
    }

    if (currentJobId === jobId) {
      self.postMessage({ type: 'done', jobId });
    }
  }
};
