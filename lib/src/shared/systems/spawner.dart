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
            new Position(400 + cos(orientation - PI) * 500.0, 300 + sin(orientation - PI) * 400.0),
            new Velocity(velocity * cos(orientation), velocity * sin(orientation)),
            new Lifetime(1000 / (1 - velocity)),
            new Color('#ffffff')]);
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
