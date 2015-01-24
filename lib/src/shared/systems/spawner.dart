part of shared;

class TriangleSpawningSystem extends VoidEntitySystem {

  var spawnTimer = 1000.0;

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
    var orientation = random.nextDouble() * 2 * PI;
    var velocity = 0.5 + random.nextDouble() * 0.5;
    world.createAndAddEntity(
        [
            new Triangle(10.0 + random.nextDouble() * 15.0),
            new Position(400 + cos(orientation - PI) * 500.0, 300 + sin(orientation - PI) * 400.0),
            new Orientation(orientation),
            new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
            new Lifetime(1000 / (1 - velocity)),
            new Color(strokeStyle: '#ffffff')]);
  }

  void spawnHorizontalMovement() {
    var velocity = 0.2 + random.nextDouble() * 0.2;
    var verticalPosBase = random.nextDouble() * 450.0;
    var size = 10.0 + random.nextDouble() * 15.0;
    var distance = 1.75 * size + random.nextDouble() * size;
    var targetAcceleration = 0.002 * random.nextDouble();

    for (int i = 0; i < random.nextInt(6); i++) {
      var orientation = random.nextInt(2) * PI;
      var acceleration = new Acceleration();

      new Tween.to(acceleration, Acceleration.VALUE, 5000)
          ..easing = TweenEquations.easeNone
          ..targetValues = [targetAcceleration]
          ..start(tweenManager);

      world.createAndAddEntity(
          [
              new Triangle(size),
              new Position(400 + cos(orientation - PI) * 500.0, verticalPosBase + distance * i),
              new Orientation(orientation),
              new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
              new Lifetime(10000.0),
              acceleration,
              new Color(strokeStyle: '#ffffff')]);
    }
  }
  void spawnVerticalMovement() {
    var velocity = 0.2 + random.nextDouble() * 0.2;
    var horizontalPosBase = random.nextDouble() * 800.0;
    var size = 10.0 + random.nextDouble() * 15.0;
    var distance = 1.75 * size + random.nextDouble() * size;
    var targetAcceleration = 0.002 * random.nextDouble();

    for (int i = 0; i < random.nextInt(6); i++) {
      var orientation = random.nextInt(2) * PI + PI / 2;
      var acceleration = new Acceleration();

      new Tween.to(acceleration, Acceleration.VALUE, 5000)
          ..easing = TweenEquations.easeNone
          ..targetValues = [targetAcceleration]
          ..start(tweenManager);

      world.createAndAddEntity(
          [
              new Triangle(size),
              new Position(horizontalPosBase + distance * i, 300 + sin(orientation - PI) * 400.0),
              new Orientation(orientation),
              new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
              new Lifetime(10000.0),
              acceleration,
              new Color(strokeStyle: '#ffffff')]);
    }
  }

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 1000.0;
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
    world.createAndAddEntity(
        [
            new Position(random.nextDouble() * 800.0, 0.0),
            new Velocity(0.0, random.nextDouble() * 0.025),
            new Color(fillStyle: '#${randomBrightColor()}${randomBrightColor()}${randomBrightColor()}'),
            new Background(1 + random.nextInt(3)),
            new Lifetime(10000.0)]);
  }

  String randomBrightColor() => (150 + random.nextInt(105)).toInt().toRadixString(16);

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 30 + random.nextDouble() * 80;
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
            new Circle(5.0),
            new Velocity(0.0, 0.0),
            new Color(fillStyle: 'white'),
            new Collectible(),
            new AttentionWhore(1000.0),
            new Heartbeat()]);
  }

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 4000 + random.nextInt(2000);
      return true;
    }
    spawnTimer -= world.delta;
    return false;
  }
}
