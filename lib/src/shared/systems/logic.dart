part of shared;


class CollisionDetectionSystem extends EntitySystem {
  GroupManager groupManager;

  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Circle> cm;
  Mapper<Health> hm;

  CollisionDetectionSystem() : super(Aspect.getAspectForAllOf([Position, Triangle]));



  @override
  void processEntities(Iterable<Entity> entities) {
    var circles = groupManager.getEntities(circleGroup);
    circles.forEach((circle) {
      var circlePos = pm[circle];
      var circleCircle = cm[circle];

      entities.forEach((entity) {
        var p = pm[entity];
        var t = tm[entity];

        var distanceCenter = sqrt((p.x - circlePos.x) * (p.x - circlePos.x) + (p.y - circlePos.y) * (p.y - circlePos.y));
        var combinedSize = circleCircle.radius + t.size;

        if (distanceCenter < combinedSize) {
          // TODO: do some fancy triangle vs circle collision detection, for now: collide!
          var h = hm[circle];
          h.value -= 1;
          if (h.value <= 0.0) {
            circle.addComponent(new CircleDestruction());
            circle.changedInWorld();
          }
        }
      });
    });
  }

  @override
  bool checkProcessing() => true;
}

class CircleDestructionSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Circle> cm;

  var processed = false;

  CircleDestructionSystem() : super(Aspect.getAspectForAllOf([Position, Circle, CircleDestruction]));

  @override
  void processEntity(Entity entity) {
    entity.deleteFromWorld();
    processed = true;
  }

  @override
  void end() {
    if (processed) {
      world.processEntityChanges();
    }
    processed = false;
  }

}