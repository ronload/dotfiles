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
//   1. Overpaint the destination cursor rect with iBackgroundColor (the
//      terminal's default background, exposed as a uniform since Ghostty
//      1.3.0). Coloured-bg cells (tmux status bar, syntax-highlighted bg,
//      selection regions) get the default bg here — not perfect, but a
//      strict improvement over sampling the previous frame, which could
//      pick up glyph foreground pixels.
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
const float BAR_DETECT_RATIO = 0.15;  // treat as bar when width < height * this (well below any block aspect ratio)

// VS Code's CSS `ease` keyword = cubic-bezier(0.25, 0.1, 0.25, 1.0): asymmetric
// S-curve that accelerates quickly out of the start and eases gently into the
// end (at progress 0.5 the cursor has already covered ~80% of the distance).
//
// CSS bezier is parametric (x(t), y(t)); given progress x we must invert to
// find t, then evaluate y(t). Because x1 == x2 == 0.25, x(t) simplifies to
// t^3 - 0.75t^2 + 0.75t, with derivative 3t^2 - 1.5t + 0.75. Four Newton-
// Raphson iterations from t = x converge to <1e-6 over [0, 1].
float ease(float x) {
    float t = x;
    for (int i = 0; i < 4; i++) {
        float xt  = t * t * t - 0.75 * t * t + 0.75 * t;
        float dxt = 3.0 * t * t - 1.5 * t + 0.75;
        t = t - (xt - x) / dxt;
    }
    float ct = 1.0 - t;
    return 0.3 * ct * ct * t + 3.0 * ct * t * t + t * t * t;
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

    float moved = step(0.5, distance(curCenter, prevCenter));
    float animating = moved * (1.0 - step(1.0, progress));

    float dCur = sdfRect(fragCoord, curCenter, curSize * 0.5);
    float insideCur = 1.0 - smoothstep(-BLUR, BLUR, dCur);
    fragColor.rgb = mix(fragColor.rgb, iBackgroundColor, insideCur * animating);

    float isCurBar  = step(curSize.x,  curSize.y  * BAR_DETECT_RATIO);
    float isPrevBar = step(prevSize.x, prevSize.y * BAR_DETECT_RATIO);
    float isBar = isCurBar * isPrevBar;

    vec2 synthSize = mix(curSize, vec2(BAR_WIDTH, curSize.y), isBar);

    vec2 synthCurCenter  = vec2(curPos.x  + synthSize.x * 0.5, curCenter.y);
    vec2 synthPrevCenter = vec2(prevPos.x + synthSize.x * 0.5, prevCenter.y);

    vec2 lerpCenter = mix(synthPrevCenter, synthCurCenter, eased);
    float dLerp = sdfRect(fragCoord, lerpCenter, synthSize * 0.5);
    float insideLerp = 1.0 - smoothstep(-BLUR, BLUR, dLerp);
    fragColor.rgb = mix(fragColor.rgb, iCurrentCursorColor.rgb,
                        insideLerp * iCurrentCursorColor.a * animating);
}
