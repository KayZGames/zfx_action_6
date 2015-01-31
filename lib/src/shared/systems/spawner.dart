part of shared;

class TriangleSpawningSystem extends VoidEntitySystem {

  var spawnTimer = 1.0;

  @override
  void processSystem() {
    switch (random.nextInt(3)) {
      case 0:
        spawnCenterOriented();
        break;
      case 1:
        spawnHorizontalMovement();
        break;
      case 2:
        spawnVerticalMovement();
        break;
    }
  }

  void spawnCenterOriented() {
    var orientation = random.nextDouble() * PI;
    var velocity = 500 + random.nextDouble() * 500;
    var size = 10.0 + random.nextDouble() * 15.0;
    var strokeStyle = generateTriangleColor();
    world.createAndAddEntity(
        [
            new Triangle(size),
            new Position(400 + cos(orientation - PI) * 500.0, 300 + sin(orientation - PI) * 400.0),
            new Orientation(orientation),
            new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
            new Lifetime(4.0),
            new Thruster(size * sin(PI / 4)),
            new Acceleration(),
            new Color(strokeStyle: strokeStyle)]);
  }

  void spawnHorizontalMovement() {
    var velocity = 200 + random.nextDouble() * 200;
    var verticalPosBase = random.nextDouble() * 450.0;
    var size = 10.0 + random.nextDouble() * 15.0;
    var distance = 2.0 * size + random.nextDouble() * size;
    var targetAcceleration = 100 * random.nextDouble();
    var strokeStyle = generateTriangleColor();

    for (int i = 0; i < random.nextInt(6); i++) {
      var orientation = random.nextInt(2) * PI;
      var acceleration = new Acceleration();

      new Tween.to(acceleration, Acceleration.VALUE, 5.0)
          ..easing = TweenEquations.easeNone
          ..targetValues = [targetAcceleration]
          ..start(tweenManager);

      world.createAndAddEntity(
          [
              new Triangle(size),
              new Position(400 + cos(orientation - PI) * 500.0, verticalPosBase + distance * i),
              new Orientation(orientation),
              new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
              new Lifetime(4.0),
              new Thruster(size * sin(PI / 4)),
              acceleration,
              new Color(strokeStyle: strokeStyle)]);
    }
  }
  void spawnVerticalMovement() {
    var velocity = 200 + random.nextDouble() * 200;
    var horizontalPosBase = random.nextDouble() * 800.0;
    var size = 10.0 + random.nextDouble() * 15.0;
    var distance = 2.0 * size + random.nextDouble() * size;
    var targetAcceleration = 100.0 * random.nextDouble();
    var strokeStyle = generateTriangleColor();

    for (int i = 0; i < random.nextInt(6); i++) {
      var orientation = PI / 2;
      var acceleration = new Acceleration();

      new Tween.to(acceleration, Acceleration.VALUE, 5.0)
          ..easing = TweenEquations.easeNone
          ..targetValues = [targetAcceleration]
          ..start(tweenManager);

      world.createAndAddEntity(
          [
              new Triangle(size),
              new Position(horizontalPosBase + distance * i, 300 + sin(orientation - PI) * 400.0),
              new Orientation(orientation),
              new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
              new Lifetime(4.0),
              new Thruster(size * sin(PI / 4)),
              acceleration,
              new Color(strokeStyle: strokeStyle)]);
    }
  }

  String generateTriangleColor() => '#00${randomBrightColorFragment()}${randomBrightColorFragment()}';

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 1.0 / max(1, gameState.friendsAlive / (gameState.rageMode ? 0.5 : 2));
      return true;
    }
    spawnTimer -= world.delta;
    return false;
  }
}

class BackgroundDotSpawner extends VoidEntitySystem {

  var spawnTimer = 0.0;

  @override
  void processSystem() {
    var minSpeed = 0.0;
    var speedMod = 25;
    if (gameState.rageMode) {
      minSpeed = 200 * gameState.rageMod;
      speedMod = 200 * gameState.rageMod;
    }
    world.createAndAddEntity(
        [
            new Position(random.nextDouble() * 800.0, 0.0),
            new Velocity(0.0, minSpeed + random.nextDouble() * speedMod),
            new Color(fillStyle: randomBrightColor()),
            new Background(1 + random.nextInt(3)),
            new Lifetime(10.0)]);
  }

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 0.03 + random.nextDouble() * 0.08;
      return true;
    }
    spawnTimer -= world.delta;
    return false;
  }
}

class FriendSpawner extends VoidEntitySystem {
  var spawnTimer = 0.0;

  @override
  void processSystem() {
    world.createAndAddEntity(
        [
            new Position(100 + random.nextDouble() * 600, -20.0),
            new Orientation(0.0),
            new Circle(5.0),
            new Velocity(0.0, 0.0),
            new Color(fillStyle: 'white'),
            new Collectible(),
            new AttentionWhore(1.0),
            new Heartbeat()]);
  }

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 4 + 2 * random.nextDouble();
      return true;
    }
    spawnTimer -= world.delta;
    return false;
  }
}
