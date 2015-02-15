precision highp float;
const vec2 center = vec2(0.5, 0.5);
varying vec4 v_Color;
void main() {
  float dist = distance(gl_PointCoord, center);
  if (dist > 0.4) {
    discard;
  }
  gl_FragColor = vec4(v_Color.rgb, 1.0 - 2.0 * dist);
}