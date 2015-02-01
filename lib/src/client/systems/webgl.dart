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
  Map<String, Buffer> buffers = <String, Buffer>{};
  int maxLength = 0;

  WebGlRenderingSystem(this.gl, Aspect aspect) : super(aspect);

  @override
  void initialize() {
    var vShader = _createShader(RenderingContext.VERTEX_SHADER, vShaderSource);
    var fShader = _createShader(RenderingContext.FRAGMENT_SHADER, fShaderSource);

    _createProgram(vShader, fShader);
  }

  void _createProgram(Shader vShader, Shader fShader) {
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

  Shader _createShader(int type, String source) {
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
      if (length > maxLength) {
        updateLength(length);
        maxLength = length;
      }
      var index = 0;
      entities.forEach((entity) {
        processEntity(index++, entity);
      });
      render(length);
    }
  }

  void buffer(String attribute, Float32List items, int itemSize) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer;
    }
    var attribLocation = gl.getAttribLocation(program, attribute);
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, RenderingContext.STREAM_DRAW);
    gl.vertexAttribPointer(attribLocation, itemSize, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(attribLocation);
  }

  @override
  bool checkProcessing() => success;

  void updateLength(int length);
  void processEntity(int index, Entity entity);
  void render(int length);
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

  BackgroundDotRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Background, Position, Color]));

  @override
  void processEntity(int index, Entity entity) {
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
  }

  @override
  void render(int length) {
    buffer('a_Position', positions, 2);
    buffer('a_PointSize', sizes, 1);
    buffer('a_FragColor', colors, 4);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2);
    colors = new Float32List(length * 4);
    sizes = new Float32List(length);
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
  int maxLength = 0;

  ParticleRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Particle, Color, Position]));

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var c = cm[entity];
    var particle = particleMapper[entity];

    positions[index * 2] = p.x;
    positions[index * 2 + 1] = p.y;
    colors[index * 4] = c.red;
    colors[index * 4 + 1] = c.green;
    colors[index * 4 + 2] = c.blue;
    colors[index * 4 + 3] = c.alpha;
  }

  @override
  void render(int length) {
    buffer('a_Position', positions, 2);
    buffer('a_Color', colors, 4);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2);
    colors = new Float32List(length * 4);
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
