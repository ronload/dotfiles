// VS Code-style smooth caret animation for Ghostty.
//
// Visual equivalent of VS Code's editor.cursorSmoothCaretAnimation: the cursor
// slides from its previous position to the new position over DURATION (80ms by
// default, matching VS Code's CSS `transition: all 80ms`).
//
// Works uniformly for block, bar, and underline cursor styles, and for any
// motion (per-character horizontal, vertical, cross-line diagonal, typing).
//
// How it works
// ------------
// Ghostty hands us the already-composited frame in iChannel0 — Ghostty has
// already drawn the cursor at iCurrentCursor. To produce a "sliding" effect
// rather than a teleport, during the animation window we:
//
//   1. Overpaint the destination cursor rect with a sampled background color.
//      The sample is taken from the previous cursor's center in the current
//      frame — since the cursor has moved away, that pixel is now whatever the
//      cell looked like without a cursor (best available "background" guess).
//
//   2. Draw a synthetic cursor at the lerped position (previous -> current)
//      using iCurrentCursorColor.
//
// At progress = 1 the shader is a no-op and Ghostty's native cursor shows
// through unchanged. If the cursor effectively didn't move (e.g., a same-cell
// repaint), animation is skipped to avoid flicker.

const float DURATION = 0.08;  // 80ms, matching VS Code
const float BLUR = 1.0;       // antialiasing edge width, in pixels
const float BAR_WIDTH = 2.0;  // synthetic bar width in device pixels (VS Code editor.cursorWidth default)
const float BAR_DETECT_RATIO = 0.3;  // treat as bar when width < height * this

// smoothstep — symmetric S-curve. CSS `ease` is asymmetric cubic-bezier(.25,.1,.25,1);
// at 80ms the difference is below the perceptual threshold, so use smoothstep.
float ease(float t) {
    return t * t * (3.0 - 2.0 * t);
}

float sdfRect(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // Ghostty cursor rects: .xy = top-left (y-up convention), .zw = (width, height).
    vec2 curPos   = iCurrentCursor.xy;
    vec2 curSize  = iCurrentCursor.zw;
    vec2 prevPos  = iPreviousCursor.xy;
    vec2 prevSize = iPreviousCursor.zw;

    vec2 curCenter  = vec2(curPos.x  + curSize.x  * 0.5, curPos.y  - curSize.y  * 0.5);
    vec2 prevCenter = vec2(prevPos.x + prevSize.x * 0.5, prevPos.y - prevSize.y * 0.5);

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float eased = ease(progress);

    // Skip animation when the cursor didn't actually move (sub-pixel) or when
    // the animation window has elapsed.
    float moved = step(0.5, distance(curCenter, prevCenter));
    float animating = moved * (1.0 - step(1.0, progress));

    // Sample a "likely background" color from the previous cursor's center in
    // the current frame. Since the cursor has moved away, this pixel is the
    // cell's cleaned-up content (most often the terminal background).
    vec2 erasePx = clamp(prevCenter, vec2(0.0), iResolution.xy - vec2(1.0));
    vec3 bgGuess = texture(iChannel0, erasePx / iResolution.xy).rgb;

    // 1. Overpaint the destination cursor rect with bgGuess during animation.
    float dCur = sdfRect(fragCoord, curCenter, curSize * 0.5);
    float insideCur = 1.0 - smoothstep(-BLUR, BLUR, dCur);
    fragColor.rgb = mix(fragColor.rgb, bgGuess, insideCur * animating);

    // 2. Draw the synthetic cursor at the lerped position.
    // For bar-style cursors, override the synthetic width to BAR_WIDTH to match
    // VS Code's editor.cursorWidth default. Block / underline keep iCurrentCursor.zw.
    // Bar detection uses aspect ratio: bar has width << height.
    float isBar = step(curSize.x, curSize.y * BAR_DETECT_RATIO);
    vec2 synthCurSize  = mix(curSize,  vec2(BAR_WIDTH, curSize.y),  isBar);
    vec2 synthPrevSize = mix(prevSize, vec2(BAR_WIDTH, prevSize.y), isBar);

    // Keep the LEFT edge aligned with Ghostty's bar position (not center-aligned),
    // so the synthetic at progress=1 lines up with Ghostty's native bar left edge.
    vec2 synthCurCenter  = vec2(curPos.x  + synthCurSize.x  * 0.5, curCenter.y);
    vec2 synthPrevCenter = vec2(prevPos.x + synthPrevSize.x * 0.5, prevCenter.y);

    vec2 lerpCenter = mix(synthPrevCenter, synthCurCenter, eased);
    vec2 lerpSize   = mix(synthPrevSize,   synthCurSize,   eased);
    float dLerp = sdfRect(fragCoord, lerpCenter, lerpSize * 0.5);
    float insideLerp = 1.0 - smoothstep(-BLUR, BLUR, dLerp);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb,
                        insideLerp * iCurrentCursorColor.a * animating);
}
