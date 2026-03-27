// ============================================================
// JAM — Julia and Mandelbrot — Main Application
// ============================================================

// --- Configurable constants ---
const DEFAULT_RANGE = 4;       // -2..2
const ZOOM_FACTOR = 10;

// --- State ---
const state = {
  mandelbrot: {
    centerR: 0, centerI: 0,
    range: DEFAULT_RANGE,
    enhanced: false
  },
  julia: {
    centerR: 0, centerI: 0,
    range: DEFAULT_RANGE,
    enhanced: false,
    c: { r: 0, i: 0 }  // c-value from Mandelbrot
  },
  reoriented: false
};

// --- DOM refs ---
const container = document.getElementById('container');
const mandelbrotCanvas = document.getElementById('mandelbrot-canvas');
const juliaCanvas = document.getElementById('julia-canvas');
const mandelbrotCtx = mandelbrotCanvas.getContext('2d');
const juliaCtx = juliaCanvas.getContext('2d');
const paneMandelbrot = document.getElementById('pane-mandelbrot');
const paneJulia = document.getElementById('pane-julia');
const reorientBtn = document.getElementById('reorient-btn');
const contextMenuEl = document.getElementById('context-menu');

// --- Workers ---
const mandelbrotWorker = new Worker('worker.js');
const juliaWorker = new Worker('worker.js');
let mandelbrotJobId = 0;
let juliaJobId = 0;

// --- Layout ---
function updateLayout() {
  const isWide = window.innerWidth >= window.innerHeight;
  container.className = isWide ? 'horizontal' : 'vertical';

  const toolbarH = document.getElementById('toolbar').offsetHeight;
  const availW = window.innerWidth - 16; // padding
  const availH = window.innerHeight - toolbarH - 16;

  let canvasW, canvasH;
  if (isWide) {
    canvasW = Math.floor((availW / 2) * 0.8);
    canvasH = Math.floor(availH * 0.8);
  } else {
    canvasW = Math.floor(availW * 0.8);
    canvasH = Math.floor((availH / 2) * 0.8);
  }

  // Keep square aspect for fractal rendering
  const size = Math.min(canvasW, canvasH);
  mandelbrotCanvas.width = size;
  mandelbrotCanvas.height = size;
  juliaCanvas.width = size;
  juliaCanvas.height = size;

  // Apply order
  if (state.reoriented) {
    container.appendChild(paneJulia);
    container.appendChild(paneMandelbrot);
  } else {
    container.appendChild(paneMandelbrot);
    container.appendChild(paneJulia);
  }
}

// --- Rendering ---

function renderMandelbrot() {
  const jobId = ++mandelbrotJobId;
  mandelbrotWorker.postMessage({ type: 'cancel' });

  const s = state.mandelbrot;
  const w = mandelbrotCanvas.width;
  const h = mandelbrotCanvas.height;

  mandelbrotWorker.postMessage({
    type: 'render',
    jobId,
    fractalType: 'mandelbrot',
    width: w, height: h,
    centerR: s.centerR, centerI: s.centerI,
    rangeR: s.range, rangeI: s.range,
    enhanced: s.enhanced
  });
}

function renderJulia(overrideEnhanced) {
  const jobId = ++juliaJobId;
  juliaWorker.postMessage({ type: 'cancel' });

  const s = state.julia;
  const w = juliaCanvas.width;
  const h = juliaCanvas.height;
  const enhanced = overrideEnhanced !== undefined ? overrideEnhanced : s.enhanced;

  juliaWorker.postMessage({
    type: 'render',
    jobId,
    fractalType: 'julia',
    width: w, height: h,
    centerR: s.centerR, centerI: s.centerI,
    rangeR: s.range, rangeI: s.range,
    enhanced,
    juliaC: s.c
  });
}

// --- Worker message handlers (progressive row rendering) ---

mandelbrotWorker.onmessage = function(e) {
  const msg = e.data;
  if (msg.type === 'row' && msg.jobId === mandelbrotJobId) {
    const arr = new Uint8ClampedArray(msg.rowData);
    const imgData = new ImageData(arr, mandelbrotCanvas.width, 1);
    mandelbrotCtx.putImageData(imgData, 0, msg.y);
  }
};

juliaWorker.onmessage = function(e) {
  const msg = e.data;
  if (msg.type === 'row' && msg.jobId === juliaJobId) {
    const arr = new Uint8ClampedArray(msg.rowData);
    const imgData = new ImageData(arr, juliaCanvas.width, 1);
    juliaCtx.putImageData(imgData, 0, msg.y);
  }
};

// --- Coordinate conversion ---

function canvasToComplex(canvas, s, x, y) {
  const w = canvas.width;
  const h = canvas.height;
  const cr = s.centerR - s.range / 2 + (x / w) * s.range;
  const ci = s.centerI - s.range / 2 + (y / h) * s.range;
  return { r: cr, i: ci };
}

// --- Drag on Mandelbrot ---

let isDragging = false;

mandelbrotCanvas.addEventListener('mousedown', (e) => {
  if (e.button === 0) {
    isDragging = true;
    updateJuliaFromMandelbrot(e, false);
  }
});

mandelbrotCanvas.addEventListener('mousemove', (e) => {
  if (isDragging) {
    updateJuliaFromMandelbrot(e, false);
  }
});

window.addEventListener('mouseup', (e) => {
  if (isDragging && e.button === 0) {
    isDragging = false;
    // Re-render at enhanced level if Julia is enhanced
    if (state.julia.enhanced) {
      renderJulia();
    }
  }
});

function updateJuliaFromMandelbrot(e, useEnhanced) {
  const rect = mandelbrotCanvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  const pt = canvasToComplex(mandelbrotCanvas, state.mandelbrot, x, y);
  state.julia.c = { r: pt.r, i: pt.i };
  // Reset Julia view to default when exploring different c-values via drag
  state.julia.centerR = 0;
  state.julia.centerI = 0;
  state.julia.range = DEFAULT_RANGE;
  // During drag, render at default (B&W) for responsiveness
  renderJulia(useEnhanced ? undefined : false);
}

// --- Context Menu ---

function showContextMenu(x, y, items) {
  contextMenuEl.innerHTML = '';
  items.forEach(item => {
    if (item === 'separator') {
      const sep = document.createElement('div');
      sep.className = 'context-menu-separator';
      contextMenuEl.appendChild(sep);
    } else {
      const el = document.createElement('div');
      el.className = 'context-menu-item';
      el.textContent = item.label;
      el.addEventListener('click', () => {
        hideContextMenu();
        item.action();
      });
      contextMenuEl.appendChild(el);
    }
  });

  contextMenuEl.style.left = x + 'px';
  contextMenuEl.style.top = y + 'px';
  contextMenuEl.classList.remove('hidden');

  // Adjust if off-screen
  const rect = contextMenuEl.getBoundingClientRect();
  if (rect.right > window.innerWidth) {
    contextMenuEl.style.left = (x - rect.width) + 'px';
  }
  if (rect.bottom > window.innerHeight) {
    contextMenuEl.style.top = (y - rect.height) + 'px';
  }
}

function hideContextMenu() {
  contextMenuEl.classList.add('hidden');
}

document.addEventListener('click', (e) => {
  if (!contextMenuEl.contains(e.target)) hideContextMenu();
});
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') hideContextMenu();
});

// --- Mandelbrot context menu ---

mandelbrotCanvas.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  const rect = mandelbrotCanvas.getBoundingClientRect();
  const cx = e.clientX - rect.left;
  const cy = e.clientY - rect.top;
  const pt = canvasToComplex(mandelbrotCanvas, state.mandelbrot, cx, cy);

  const items = [
    {
      label: 'Zoom in 10×',
      action: () => {
        state.mandelbrot.centerR = pt.r;
        state.mandelbrot.centerI = pt.i;
        state.mandelbrot.range /= ZOOM_FACTOR;
        renderMandelbrot();
        // Mirror zoom to Julia set
        const jPt = canvasToComplex(juliaCanvas, state.julia,
          cx / mandelbrotCanvas.width * juliaCanvas.width,
          cy / mandelbrotCanvas.height * juliaCanvas.height);
        state.julia.centerR = jPt.r;
        state.julia.centerI = jPt.i;
        state.julia.range /= ZOOM_FACTOR;
        renderJulia();
      }
    },
    {
      label: 'Zoom out 10×',
      action: () => {
        state.mandelbrot.centerR = pt.r;
        state.mandelbrot.centerI = pt.i;
        state.mandelbrot.range *= ZOOM_FACTOR;
        renderMandelbrot();
        // Mirror zoom to Julia set
        const jPt = canvasToComplex(juliaCanvas, state.julia,
          cx / mandelbrotCanvas.width * juliaCanvas.width,
          cy / mandelbrotCanvas.height * juliaCanvas.height);
        state.julia.centerR = jPt.r;
        state.julia.centerI = jPt.i;
        state.julia.range *= ZOOM_FACTOR;
        renderJulia();
      }
    },
    {
      label: 'Reset',
      action: () => {
        state.mandelbrot.centerR = 0;
        state.mandelbrot.centerI = 0;
        state.mandelbrot.range = DEFAULT_RANGE;
        state.mandelbrot.enhanced = false;
        renderMandelbrot();
      }
    },
    'separator',
    {
      label: 'Enhance',
      action: () => {
        state.mandelbrot.enhanced = true;
        renderMandelbrot();
      }
    },
    {
      label: 'Unenhance',
      action: () => {
        state.mandelbrot.enhanced = false;
        renderMandelbrot();
      }
    }
  ];

  showContextMenu(e.clientX, e.clientY, items);
});

// --- Julia context menu ---

juliaCanvas.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  const rect = juliaCanvas.getBoundingClientRect();
  const cx = e.clientX - rect.left;
  const cy = e.clientY - rect.top;
  const pt = canvasToComplex(juliaCanvas, state.julia, cx, cy);

  const items = [
    {
      label: 'Zoom in 10×',
      action: () => {
        state.julia.centerR = pt.r;
        state.julia.centerI = pt.i;
        state.julia.range /= ZOOM_FACTOR;
        renderJulia();
      }
    },
    {
      label: 'Zoom out 10×',
      action: () => {
        state.julia.centerR = pt.r;
        state.julia.centerI = pt.i;
        state.julia.range *= ZOOM_FACTOR;
        renderJulia();
      }
    },
    {
      label: 'Reset',
      action: () => {
        state.julia.centerR = 0;
        state.julia.centerI = 0;
        state.julia.range = DEFAULT_RANGE;
        state.julia.enhanced = false;
        renderJulia();
      }
    },
    'separator',
    {
      label: 'Enhance',
      action: () => {
        state.julia.enhanced = true;
        renderJulia();
      }
    },
    {
      label: 'Unenhance',
      action: () => {
        state.julia.enhanced = false;
        renderJulia();
      }
    },
    'separator',
    {
      label: 'Center Mandelbrot here',
      action: () => {
        state.mandelbrot.centerR = state.julia.c.r;
        state.mandelbrot.centerI = state.julia.c.i;
        renderMandelbrot();
      }
    }
  ];

  showContextMenu(e.clientX, e.clientY, items);
});

// --- Reorient ---

reorientBtn.addEventListener('click', () => {
  state.reoriented = !state.reoriented;
  updateLayout();
});

// --- Resize ---

let resizeTimer;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => {
    updateLayout();
    renderMandelbrot();
    renderJulia();
  }, 150);
});

// --- Init ---

updateLayout();
renderMandelbrot();
renderJulia();
