part of client;

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
    sizes = new Float32List(length);
  }

  String get fShaderFile => 'basicColor';
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
  String get fShaderFile => 'basicColor';
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
    // fancy colors
    colors[index * 12] = 1.0;
    colors[index * 12 + 1] = c.blue;
    colors[index * 12 + 2] = c.green;
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
  String get vShaderFile => 'basicTriangles';

  @override
  String get fShaderFile => 'basicColor';
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
      positions[posIndex + 4] = position.x + radius * cos(2 * PI * (triangle + 1) / maxTriangles);
      positions[posIndex + 5] = position.y + radius * sin(2 * PI * (triangle + 1) / maxTriangles);
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
  String get vShaderFile => 'basicTriangles';

  @override
  String get fShaderFile => 'basicColor';
}

class PainometerRenderingSystem extends VoidWebGlRenderingSystem {
  Float32List positions = new Float32List(8);
  Float32List colors = new Float32List(16);
  PainometerRenderingSystem(RenderingContext gl) : super(gl);

  void initialize() {
    super.initialize();
    positions[0] = 100.0;
    positions[1] = 570.0;
    positions[2] = 100.0;
    positions[3] = 590.0;
    // x of bottom right vertex
    positions[5] = 590.0;
    // x of top right vertex
    positions[7] = 570.0;

    colors[0] = 0.0;
    colors[1] = 0.5;
    colors[2] = 0.0;
    colors[3] = 1.0;
    colors[4] = 0.0;
    colors[5] = 0.5;
    colors[6] = 0.0;
    colors[7] = 1.0;
    colors[10] = 0.0;
    colors[11] = 1.0;
    colors[14] = 0.0;
    colors[15] = 1.0;
  }

  @override
  void render() {
    var painometer = min(100.0, gameState.painometer);
    positions[4] = 100.0 + painometer * 6.0;
    positions[6] = 100.0 + painometer * 6.0;

    colors[8] = painometer / 100.0;
    colors[9] = 0.5 - painometer / 200.0;
    colors[12] = painometer / 100.0;
    colors[13] = 0.5 - painometer / 200.0;

    buffer('a_Position', positions, 2);
    buffer('a_Color', colors, 4);

    gl.drawArrays(RenderingContext.TRIANGLE_FAN, 0, 4);
  }

  @override
  String get fShaderFile => 'basicColor';
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
