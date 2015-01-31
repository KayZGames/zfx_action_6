part of client;

class CanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext gl;

  CanvasCleaningSystem(this.gl);

  @override
  void processSystem() {
    gl
        ..clearColor(0, 0, 0, 1)
        ..clear(RenderingContext.COLOR_BUFFER_BIT);
  }
}

class BackgroundDotRenderingSystem extends EntitySystem {
  Mapper<Position> pm;
  Mapper<Color> cm;
  Mapper<Background> bm;

  RenderingContext gl;
  Program program;
  bool success = true;

  static const String vShaderSource = '''
attribute vec4 a_Position;
attribute vec4 a_FragColor;
attribute float a_PointSize;
varying vec4 v_FragColor;
void main() {
  gl_Position = a_Position;
  gl_PointSize = a_PointSize;
  v_FragColor = a_FragColor;
}
''';
  static const fShaderSource = '''
precision highp float;
varying vec4 v_FragColor;
void main() {
  gl_FragColor = v_FragColor;
}
''';
  BackgroundDotRenderingSystem(this.gl) : super(Aspect.getAspectForAllOf([Background, Position, Color]));

  @override
  void initialize() {
    var vShader = createShader(RenderingContext.VERTEX_SHADER, vShaderSource);
    var fShader = createShader(RenderingContext.FRAGMENT_SHADER, fShaderSource);

    program = gl.createProgram();
    gl.attachShader(program, vShader);
    gl.attachShader(program, fShader);
    gl.linkProgram(program);
    var linkSuccess = gl.getProgramParameter(program, RenderingContext.LINK_STATUS);
    if (!linkSuccess) {
      print('Error linking program: ${gl.getProgramInfoLog(program)}');
      success = false;
    }
  }

  createShader(int type, String source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var compileSuccess = gl.getShaderParameter(shader, RenderingContext.COMPILE_STATUS);
    if (!compileSuccess) {
      print('Error compiling shader: ${gl.getShaderInfoLog(shader)}');
      success = false;
    }
    return shader;
  }


  @override
  void begin() {
    gl.useProgram(program);
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    var length = entities.length;
    if (length > 0) {
      var a_Position = gl.getAttribLocation(program, 'a_Position');
      var a_PointSize = gl.getAttribLocation(program, 'a_PointSize');
      var a_FragColor = gl.getAttribLocation(program, 'a_FragColor');
      var positions = new Float32List(length * 2);
      var sizes = new Float32List(length);
      var colors = new Float32List(length * 4);
      var index = 0;
      entities.forEach((entity) {
        var p = pm[entity];
        var c = cm[entity];
        var b = bm[entity];

        positions[index * 2] = p.x / 400 - 1;
        positions[index * 2 + 1] = -(p.y / 300 - 1);
        sizes[index] = b.size;
        colors[index * 4] = c.red;
        colors[index * 4 + 1] = c.green;
        colors[index * 4 + 2] = c.blue;
        colors[index * 4 + 3] = c.alpha;

        index++;
      });
      buffer(a_Position, positions, 2);
      buffer(a_PointSize, sizes, 1);
      buffer(a_FragColor, colors, 4);

      gl.drawArrays(RenderingContext.POINTS, 0, length);
    }
  }

  void buffer(int index, Float32List items, int itemSize) {
    var vertexBuffer = gl.createBuffer();
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, RenderingContext.STATIC_DRAW);
    gl.vertexAttribPointer(index, itemSize, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(index);
  }

  @override
  bool checkProcessing() => success;
}
