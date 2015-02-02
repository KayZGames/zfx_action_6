uniform mat4 uModelMatrix;
attribute vec2 a_Position;
attribute vec4 a_Color;
varying vec4 v_Color;
void main() {
  gl_Position = uModelMatrix * vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
  gl_PointSize = 1.0;
  v_Color = a_Color;
}