attribute vec2 aPosition;
attribute vec4 aColor;
varying vec4 vColor;
void main() {
  gl_Position = vec4(aPosition.x / 400.0 - 1.0, -(aPosition.y / 300.0 - 1.0), 0.0, 1.0);
  vColor = aColor;
}