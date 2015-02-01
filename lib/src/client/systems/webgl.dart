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
  void processEntities(Iterable<Entity> entities) {
    var length = entities.length;
    if (length > 0) {
      gl.useProgram(program);
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
  TagManager tm;
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

    var modelMatrix = createModelMatrix(tm, pm);
    var uModelMatrix = gl.getUniformLocation(program, 'uModelMatrix');
    gl.uniformMatrix4fv(uModelMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2);
    colors = new Float32List(length * 4);
    sizes = new Float32List(length);
  }

  String get vShaderSource => '''
uniform mat4 uModelMatrix;
attribute vec2 a_Position;
attribute float a_PointSize;
attribute vec4 a_FragColor;
varying vec4 v_FragColor;
void main() {
  gl_Position = uModelMatrix * vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
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
  TagManager tm;
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

    var modelMatrix = createModelMatrix(tm, pm);
    var uModelMatrix = gl.getUniformLocation(program, 'uModelMatrix');
    gl.uniformMatrix4fv(uModelMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2);
    colors = new Float32List(length * 4);
  }

  @override
  String get vShaderSource => '''
uniform mat4 uModelMatrix;
attribute vec2 a_Position;
attribute vec4 a_Color;
varying vec4 v_Color;
void main() {
  gl_Position = uModelMatrix * vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
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


class TriangleRenderingSystem extends WebGlRenderingSystem {
  TagManager tagManager;
  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Color> cm;
  Mapper<Orientation> om;
  double beatMod = 1.0;
  Float32List positions;
  Float32List colors;

  TriangleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, Triangle, Color, Orientation]));

  @override
  void begin() {
    var mod = sin(world.time / 0.14);
    beatMod = 1 + (mod * mod * mod * mod) / 2;
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var t = tm[entity];
    var c = cm[entity];
    var o = om[entity];

    var angle = o.value;

    var size = t.size * beatMod;

    for (int vertex = 0; vertex < 3; vertex++) {
      var posIndex = index * 6 + vertex * 2;
      var colorIndex = index * 12 + vertex * 4;
      var vertexAngle = angle + PI * 2 * vertex / 3;

      positions[posIndex] = p.x + cos(vertexAngle) * size;
      positions[posIndex + 1] = p.y + sin(vertexAngle) * size;

      colors[colorIndex] = c.red;
      colors[colorIndex + 1] = c.green;
      colors[colorIndex + 2] = c.blue;
      colors[colorIndex + 3] = c.alpha;
    }
  }


  @override
  void render(int length) {
    buffer('a_Position', positions, 2);
    buffer('a_Color', colors, 4);

    var modelMatrix = createModelMatrix(tagManager, pm);
    var uModelMatrix = gl.getUniformLocation(program, 'uModelMatrix');
    gl.uniformMatrix4fv(uModelMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.TRIANGLES, 0, length * 3);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2 * 3);
    colors = new Float32List(length * 4 * 3);
  }

  @override
  String get vShaderSource => '''
uniform mat4 uModelMatrix;
attribute vec2 a_Position;
attribute vec4 a_Color;
varying vec4 v_Color;
void main() {
  gl_Position = uModelMatrix * vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
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

class CircleRenderingSystem extends WebGlRenderingSystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Circle> circleMapper;
  Mapper<Color> colorMapper;
  Mapper<Heartbeat> hbMapper;

  Float32List positions;
  Float32List colors;

  int maxTriangles = 16;
  int vertices = 3;

  CircleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, Circle, Color, Heartbeat]));

  @override
  void processEntity(int index, Entity entity) {
    var position = pm[entity];
    var circle = circleMapper[entity];
    var color = colorMapper[entity];
    var hb = hbMapper[entity];

    var beat = 60 / hb.frequency;
    var mod = 0.01;
    var red = color.red;
    var green = color.green;
    var blue = color.blue;
    if (gameState.rageMode) {
      // hacky hacky hack
      if (blue != 1.0) {
        beat = 250;
        mod = 0.025;
        red = 138 / 255;
        green = 7 / 255;
        blue = 7 / 255;
      }
    }
    var heartbeatMod = world.time % beat;
    var radius = circle.radius;
    if (heartbeatMod > 0.8 * beat) {
      radius = radius + (1000 * heartbeatMod / beat - 800) * mod;
    }
    for (int triangle = 0; triangle < maxTriangles; triangle++) {
      for (int vertex = 0; vertex < vertices; vertex++) {
        var colorIndex = ((index * maxTriangles + triangle) * vertices + vertex) * 4;

        colors[colorIndex] = red;
        colors[colorIndex + 1] = green;
        colors[colorIndex + 2] = blue;
        colors[colorIndex + 3] = color.alpha;
      }
      var posIndex = (index * maxTriangles + triangle) * 2 * vertices;
      positions[posIndex] = position.x;
      positions[posIndex + 1] = position.y;
      positions[posIndex + 2] = position.x + radius * cos(2 * PI * triangle / maxTriangles);
      positions[posIndex + 3] = position.y + radius * sin(2 * PI * triangle / maxTriangles);
      positions[posIndex + 4] = position.x + radius * cos(2 * PI * (triangle+1) / maxTriangles);
      positions[posIndex + 5] = position.y + radius * sin(2 * PI * (triangle+1) / maxTriangles);
    }
  }


  @override
  void render(int length) {
    buffer('a_Position', positions, 2);
    buffer('a_Color', colors, 4);

    var modelMatrix = createModelMatrix(tm, pm);
    var uModelMatrix = gl.getUniformLocation(program, 'uModelMatrix');
    gl.uniformMatrix4fv(uModelMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.TRIANGLES, 0, length * maxTriangles * vertices);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2 * maxTriangles * vertices);
    colors = new Float32List(length * 4 * maxTriangles * vertices);
  }

  @override
  String get vShaderSource => '''
uniform mat4 uModelMatrix;
attribute vec2 a_Position;
attribute vec4 a_Color;
varying vec4 v_Color;
void main() {
  gl_Position = uModelMatrix * vec4(a_Position.x / 400.0 - 1.0, -(a_Position.y / 300.0 - 1.0), 0.0, 1.0);
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

Matrix4 createModelMatrix(TagManager tm, Mapper<Position> pm) {
  var player = tm.getEntity(playerTag);
  var angle = 0.0;
  if (null != player) {
    angle = PI / 8 * (pm[player].x / 400.0 - 1);
  }
  var modelMatrix = new Matrix4.rotationY(angle);
  return modelMatrix;
}
