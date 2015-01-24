part of shared;

class TriangleSpawningSystem extends VoidEntitySystem {

  var spawnTimer = 1000.0;

  @override
  void processSystem() {
    var orientation = random.nextDouble() * 2 * PI;
    var velocity = 0.5 + random.nextDouble() * 0.5;
    world.createAndAddEntity(
        [
            new Triangle(15.0 + random.nextDouble() * 10.0, orientation),
            new Position(
                400 + cos(orientation - PI) * 500.0,
                300 + sin(orientation - PI) * 400.0),
            new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
            new Lifetime(1000 / (1 - velocity)),
            new Color(strokeStyle: '#ffffff')]);
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
    world.createAndAddEntity([new Position(random.nextDouble() * 800.0, 0.0),
      new Velocity(0.0, 0.0),
      new Color(fillStyle: '#${randomBrightColor()}${randomBrightColor()}${randomBrightColor()}'),
      new Background(1 + random.nextInt(3)),
      new Lifetime(10000.0)]);
  }

  String randomBrightColor() => (150 + random.nextInt(105)).toInt().toRadixString(16);

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 50 + random.nextDouble() * 100;
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
    world.createAndAddEntity([new Position(random.nextDouble() * 800, -20.0),
      new Circle(5.0),
      new Velocity(0.0, 0.0),
      new Color(fillStyle: 'white'),
      new Collectible(),
      new AttentionWhore(1000.0),
      new Heartbeat()
      ]);
  }

  @override
  bool checkProcessing() {
    if (spawnTimer <= 0) {
      spawnTimer = 8000 + random.nextInt(4000);
      return true;
    }
    spawnTimer -= world.delta;
    return false;
  }
}
