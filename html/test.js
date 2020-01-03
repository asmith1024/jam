const map = new WeakMap();

const mX = -0.5;
const mY = 0.0;
const mScale = 0.01;

const jX = 0.0;
const jY = 0.0;
const cX = 0.0;
const cY = 0.0;
const jScale = 0.028;
/*
    ids has the following properties:
    img - id of image element
    x - id of X-value text element
    y - id of Y-value text element
    scale - id of scale-value text element

    meta has the following properies:
    scale - pixel step/scale factor
    x - image center X/Real value
    y - image center Y/Imaginary value
*/
function initImage(ids, meta) {
    let scale = document.getElementById(ids.scale);
    scale.value = meta.scale;
    let img = document.getElementById(ids.img);
    initImageContext(
        img, 
        {
            textX: document.getElementById(ids.x),
            textY: document.getElementById(ids.y),
            // TODO: don't calculate image offsets - get them from API metadata
            imgX: meta.x - mid(img.width) * meta.scale,
            imgY: meta.y + mid(img.height) * meta.scale,
            scale: meta.scale
        }
    );  
    img.addEventListener("mousemove", handleMouseMove, false);
}
/*
    Javascript equivalent of Jam.top_left_offset - TODO: API call for metadata instead
*/
function topLeftOffset(center, scale, pixels) {
    return center - mid(pixels) * scale;
}
/*
    Javascript equivalent of Jam.mid - TODO: API call for metadata instead
*/
function mid(n) {
    let m = Math.trunc(n / 2);
    return n % 2 == 1 ? m + 1 : m; 
}
/*
    image - image element for this context
    context has the following properties:
    textX - text element for rendering X values
    textY - text element for rendering Y values
    imgX - image X offset
    imgY - image Y offset
    scale - resolution or scale of each image/pixel
*/
function initImageContext(image, context) {
    map.set(image, context);
}

function handleMouseMove(event) {
    let rect = event.target.getBoundingClientRect();
    let context = map.get(event.target);
    context.textX.value = context.imgX + (event.clientX - rect.left) * context.scale;
    context.textY.value = context.imgY - (event.clientY - rect.top) * context.scale;
}
