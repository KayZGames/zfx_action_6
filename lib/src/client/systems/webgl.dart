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

    positions[index * 3] = p.x;
    positions[index * 3 + 1] = p.y;
    positions[index * 3 + 2] = p.z;
    sizes[index] = b.size;
    colors[index * 4] = c.red;
    colors[index * 4 + 1] = c.green;
    colors[index * 4 + 2] = c.blue;
    colors[index * 4 + 3] = c.alpha;
  }

  @override
  void render(int length) {
    buffer('aPosition', positions, 3);
    buffer('aPointSize', sizes, 1);
    buffer('aColor', colors, 4);

    var modelMatrix = createViewProjectionMatrix(tm, world);
    var uViewProjectionMatrix = gl.getUniformLocation(program, 'uViewProjectionMatrix');
    gl.uniformMatrix4fv(uViewProjectionMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 3);
    colors = new Float32List(length * 4);
    sizes = new Float32List(length);
  }

  @override
  String get fShaderFile => 'BackgroundDotRenderingSystem';

  @override
  String get vShaderFile => 'BackgroundDotRenderingSystem';
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

    positions[index * 3] = p.x;
    positions[index * 3 + 1] = p.y;
    positions[index * 3 + 2] = p.z;
    colors[index * 4] = c.red;
    colors[index * 4 + 1] = c.green;
    colors[index * 4 + 2] = c.blue;
    colors[index * 4 + 3] = c.alpha;
  }

  @override
  void render(int length) {
    buffer('aPosition', positions, 3);
    buffer('aColor', colors, 4);

    var modelMatrix = createViewProjectionMatrix(tm, world);
    var uViewProjectionMatrix = gl.getUniformLocation(program, 'uViewProjectionMatrix');
    gl.uniformMatrix4fv(uViewProjectionMatrix, false, modelMatrix.storage);

    gl.drawArrays(RenderingContext.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 3);
    colors = new Float32List(length * 4);
  }

  @override
  String get fShaderFile => 'basicColor';

  @override
  String get vShaderFile => 'ParticleRenderingSystem';
}


class TriangleRenderingSystem extends WebGlRenderingSystem {
  TagManager tagManager;
  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Color> cm;
  Mapper<Orientation> om;
  double beatMod = 1.0;
  Float32List positionsAndColors;
  Uint16List indices;
  static const indexCount = 12;
  static const verticesPerTriangle = 6;
  static const sizePerVertex = 7;
  static const sizePerTriangle = verticesPerTriangle * sizePerVertex;

  TriangleRenderingSystem(RenderingContext gl)
      : super(gl, Aspect.getAspectForAllOf([Position, Triangle, Color, Orientation]));

  @override
  void begin() {
    var mod = sin(time / 0.14);
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


    setVertex(index * sizePerTriangle, p.x + cos(angle) * size, p.y + sin(angle) * size, p.z, c);
    setVertex(index * sizePerTriangle + 7, p.x + cos(angle + PI * 2 / 3) * size, p.y + sin(angle + PI * 2 / 3) * size, p.z, c);
    setVertex(index * sizePerTriangle + 14, p.x + cos(angle + PI * 4 / 3) * size, p.y + sin(angle + PI * 4 / 3) * size, p.z, c);
    setVertex(index * sizePerTriangle + 21, p.x - cos(angle) * size, p.y - sin(angle) * size, p.z - size, c);
    setVertex(index * sizePerTriangle + 28, p.x - cos(angle - PI/4) * size/2, p.y - sin(angle - PI/4) * size/2, p.z - size/2, c);
    setVertex(index * sizePerTriangle + 35, p.x - cos(angle + PI/4) * size/2, p.y - sin(angle + PI/4) * size/2, p.z - size/2, c);

    indices[index * indexCount + 0] = index * verticesPerTriangle + 0;
    indices[index * indexCount + 1] = index * verticesPerTriangle + 1;
    indices[index * indexCount + 2] = index * verticesPerTriangle + 4;

    indices[index * indexCount + 3] = index * verticesPerTriangle + 0;
    indices[index * indexCount + 4] = index * verticesPerTriangle + 4;
    indices[index * indexCount + 5] = index * verticesPerTriangle + 3;

    indices[index * indexCount + 6] = index * verticesPerTriangle + 0;
    indices[index * indexCount + 7] = index * verticesPerTriangle + 3;
    indices[index * indexCount + 8] = index * verticesPerTriangle + 5;

    indices[index * indexCount + 9] = index * verticesPerTriangle + 0;
    indices[index * indexCount + 10] = index * verticesPerTriangle + 5;
    indices[index * indexCount + 11] = index * verticesPerTriangle + 2;

    // fancy colors
    positionsAndColors[index * sizePerTriangle + 3] = 1.0;
    positionsAndColors[index * sizePerTriangle + 4] = c.blue;
    positionsAndColors[index * sizePerTriangle + 5] = c.green;
  }

  void setVertex(int posIndex, double x, double y, double z, Color c) {
    positionsAndColors[posIndex] = x;
    positionsAndColors[posIndex + 1] = y;
    positionsAndColors[posIndex + 2] = z;

    positionsAndColors[posIndex + 3] = c.red;
    positionsAndColors[posIndex + 4] = c.green;
    positionsAndColors[posIndex + 5] = c.blue;
    positionsAndColors[posIndex + 6] = c.alpha;
  }


  @override
  void render(int length) {
    bufferElements([const Attrib('aPosition', 3), const Attrib('aColor', 4)], positionsAndColors, indices);

    var modelMatrix = createViewProjectionMatrix(tagManager, world);
    var uViewProjectionMatrix = gl.getUniformLocation(program, 'uViewProjectionMatrix');
    gl.uniformMatrix4fv(uViewProjectionMatrix, false, modelMatrix.storage);

    gl.drawElements(RenderingContext.TRIANGLES, length * indexCount, RenderingContext.UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    positionsAndColors = new Float32List(length * sizePerTriangle);
    indices = new Uint16List(length * indexCount);
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
    var heartbeatMod = time % beat;
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
    buffer('aPosition', positions, 2);
    buffer('aColor', colors, 4);

    var modelMatrix = createViewProjectionMatrix(tm, world);
    var uViewProjectionMatrix = gl.getUniformLocation(program, 'uViewProjectionMatrix');
    gl.uniformMatrix4fv(uViewProjectionMatrix, false, modelMatrix.storage);

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

    buffer('aPosition', positions, 2);
    buffer('aColor', colors, 4);

    gl.drawArrays(RenderingContext.TRIANGLE_FAN, 0, 4);
  }

  @override
  String get fShaderFile => 'basicColor';

  @override
  String get vShaderFile => 'PainometerRenderingSystem';
}


Matrix4 createViewProjectionMatrix(TagManager tm, World world) {
  var pm = new Mapper<Position>(Position, world);
  var cm = new Mapper<Camera>(Camera, world);

  var player = tm.getEntity(playerTag);
  var cameraEntity = tm.getEntity(cameraTag);
  var camera = cm[cameraEntity];
  var angle = 0.0;
  if (null != player) {
    angle = PI / 8 * (pm[player].x / 400.0 - 1);
  }
  var viewMatrix = new Matrix4.identity();
  var projMatrix = new Matrix4.identity();
  setViewMatrix(
      viewMatrix,
      new Vector3(400.0 + 100 * sin(angle), 550.0, -150.0),
      new Vector3(400.0, 200.0, 150.0),
      new Vector3(0.0, -1.0, 0.0));
  setPerspectiveMatrix(projMatrix, PI / 2, 4 / 3, 1, 1000);
  var threedViewProjextionMatrix = projMatrix * viewMatrix;
  var twodOrthographicMatrix = new Matrix4.identity();
  setOrthographicMatrix(twodOrthographicMatrix, 00, 800, 600, 0, 250, -250);

  return threedViewProjextionMatrix * camera.three + twodOrthographicMatrix * camera.two;
}
