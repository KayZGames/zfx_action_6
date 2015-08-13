uniform mat4 uViewProjectionMatrix;
attribute vec4 aPosition;
attribute float aPointSize;
attribute vec4 aColor;
varying vec4 vColor;
void main() {
  gl_Position = uViewProjectionMatrix * aPosition;
  gl_PointSize = aPointSize;
  vColor = aColor;
}