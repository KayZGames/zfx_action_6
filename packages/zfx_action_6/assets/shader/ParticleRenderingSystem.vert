uniform mat4 uViewProjectionMatrix;
attribute vec4 aPosition;
attribute vec4 aColor;
varying vec4 vColor;
void main() {
  gl_Position = uViewProjectionMatrix * aPosition;
  gl_PointSize = 1.0;
  vColor = aColor;
}