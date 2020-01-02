const map = new WeakMap();

function initImage(idImg, idX, idY, idScale, scale) {
    let scaleJ = document.getElementById(idScale);
    scaleJ.value = scale;
    let jImg = document.getElementById(idImg);
    jImg.addEventListener("mousemove", handleMouseMove, false);
    initImageContext(
        jImg, 
        {
            textX: document.getElementById(idX),
            textY: document.getElementById(idY),
            scale: scale
        }
    );  
}

/*
    image - image element for this context
    context has the following properties:
    textX - text element for rendering X values
    textY - text element for rendering Y values
    scale - resolution or scale of the image/pixel
*/
function initImageContext(image, context) {
    map.set(image, context);
}

function handleMouseMove(event) {
    let context = map.get(event.target);
    context.textX.value = event.clientX * context.scale;
    context.textY.value = event.clientY * context.scale;
}
