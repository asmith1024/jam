const map = new WeakMap();
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
function initImage(ids) {
    let scale = document.getElementById(ids.scale);
    let img = document.getElementById(ids.img);
    let meta = metaFromUrl(img.src);
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
    scale.value = meta.scale;
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
/*
    returns { x, y, scale } from an image URL
    assumes j/m/jam task file naming convention 
    r{centerX}i{centerY}[cr{cX}ci{cY}]s{s}(j|m).bmp
    (cr and ci components are only present if the image is of a Julia set)
*/
function metaFromUrl(src) {
    let pathPos = src.lastIndexOf("/");
    filename = pathPos < 0 ? src : src.substring(pathPos + 1);
    let rStart = filename.indexOf("r") + 1;
    let rEnd = filename.indexOf("i");
    let iStart = rEnd + 1;
    let sPos = filename.lastIndexOf("s");
    let jPos = filename.lastIndexOf("j");
    let mPos = filename.lastIndexOf("m");
    let sEnd = jPos < 0 ? mPos : jPos;
    let iEnd = jPos < 0 ? sPos : filename.lastIndexOf("cr");
    let sStart = sPos + 1;
    return {
        x: parseFloat(filename.substring(rStart, rEnd)),
        y: parseFloat(filename.substring(iStart, iEnd)),
        scale: parseFloat(filename.substring(sStart, sEnd))
    };
}

function handleMouseMove(event) {
    let rect = event.target.getBoundingClientRect();
    let context = map.get(event.target);
    context.textX.value = context.imgX + (event.clientX - rect.left) * context.scale;
    context.textY.value = context.imgY - (event.clientY - rect.top) * context.scale;
}
