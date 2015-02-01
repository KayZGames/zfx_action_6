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

abstract class WebGlRenderingSystem extends EntitySystem {
  RenderingContext gl;
  Program program;
  bool success = true;
  WebGlRenderingSystem(this.gl, Aspect aspect) : super(aspect);
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

  Buffer buffer(int index, Float32List items, int itemSize, Buffer buffer) {
    var vertexBuffer = null == buffer ? gl.createBuffer() : buffer;
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, RenderingContext.STREAM_DRAW);
    gl.vertexAttribPointer(index, itemSize, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(index);
    return vertexBuffer;
  }

  @override
  bool checkProcessing() => success;

  String get vShaderSource;
  String get fShaderSource;
}

class BackgroundDotRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;
  Mapper<Background> bm;
  Float32List positions;
  Float32List colors;
  Float32List sizes;
  Buffer positionsBuffer;
  Buffer colorsBuffer;
  Buffer sizesBuffer;
  int maxLength = 0;

  BackgroundDotRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Background, Position, Color]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var length = entities.length;
    if (length > 0) {
      var a_Position = gl.getAttribLocation(program, 'a_Position');
      var a_PointSize = gl.getAttribLocation(program, 'a_PointSize');
      var a_FragColor = gl.getAttribLocation(program, 'a_FragColor');
      if (length > maxLength) {
        positions = new Float32List(length * 2);
        colors = new Float32List(length * 4);
        sizes = new Float32List(length);
        maxLength = length;
      }
      var index = 0;
      entities.forEach((entity) {
        var p = pm[entity];
        var c = cm[entity];
        var b = bm[entity];

        positions[index * 2] = p.x;
        positions[index * 2 + 1] = p.y;
        sizes[index] = b.size;
        colors[index * 4] = c.red;
        colors[index * 4 + 1] = c.green;
        colors[index * 4 + 2] = c.blue;
        colors[index * 4 + 3] = c.alpha;

        index++;
      });
      positionsBuffer = buffer(a_Position, positions, 2, positionsBuffer);
      sizesBuffer = buffer(a_PointSize, sizes, 1, sizesBuffer);
      colorsBuffer = buffer(a_FragColor, colors, 4, colorsBuffer);

      gl.drawArrays(RenderingContext.POINTS, 0, length);
    }
  }

  String get vShaderSource => '''
attribute vec2 a_Position;
attribute float a_PointSize;
attribute vec4 a_FragColor;
varying vec4 v_FragColor;
void main() {
  gl_Position = vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
  gl_PointSize = a_PointSize;
  v_FragColor = a_FragColor;
}
''';
  String get fShaderSource => '''
precision highp float;
varying vec4 v_FragColor;
void main() {
  gl_FragColor = v_FragColor;
}
''';
}

class ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Color> cm;
  Mapper<Position> pm;
  Mapper<Particle> particleMapper;
  Float32List positions;
  Float32List colors;
  Buffer positionsBuffer;
  Buffer colorsBuffer;
  int maxLength = 0;

  ParticleRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Particle, Color, Position]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var length = entities.length;
    if (length > 0) {
      var a_Position = gl.getAttribLocation(program, 'a_Position');
      var a_Color = gl.getAttribLocation(program, 'a_Color');

      if (length > maxLength) {
        positions = new Float32List(length * 2);
        colors = new Float32List(length * 4);
        maxLength = length;
      }
      var index = 0;
      entities.forEach((entity) {
        var p = pm[entity];
        var c = cm[entity];
        var particle = particleMapper[entity];

        positions[index * 2] = p.x;
        positions[index * 2 + 1] = p.y;
        colors[index * 4] = c.red;
        colors[index * 4 + 1] = c.green;
        colors[index * 4 + 2] = c.blue;
        colors[index * 4 + 3] = c.alpha;

        index++;
      });

      positionsBuffer = buffer(a_Position, positions, 2, positionsBuffer);
      colorsBuffer = buffer(a_Color, colors, 4, colorsBuffer);

      gl.drawArrays(RenderingContext.POINTS, 0, length);
    }
  }


  @override
  String get vShaderSource => '''
attribute vec2 a_Position;
attribute vec4 a_Color;
varying vec4 v_Color;
void main() {
  gl_Position = vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
  gl_PointSize = 1.0;
  v_Color = a_Color;
}
''';

  @override
  String get fShaderSource => '''
precision highp float;
varying vec4 v_Color;
void main() {
  gl_FragColor = v_Color;
}
''';

}
