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

        var distanceCenter = p.distanceTo(circlePos);
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

class MovementSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;
  static const double pretendMovementY = 0.1;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    p.x += v.x * world.delta;
    p.y += (v.y + pretendMovementY) * world.delta;
  }
}

class LifetimeSystem extends EntityProcessingSystem {
  Mapper<Lifetime> lm;

  LifetimeSystem() : super(Aspect.getAspectForAllOf([Lifetime]));

  @override
  void processEntity(Entity entity) {
    var l = lm[entity];
    l.value -= world.delta;
    if (l.value <= 0.0) {
      entity.deleteFromWorld();
    }
  }
}

class FriendCollectingSystem extends EntitySystem {
  TagManager tm;
  GroupManager gm;
  Mapper<Position> pm;
  Mapper<Circle> cm;

  FriendCollectingSystem() : super(Aspect.getAspectForAllOf([Collectible, Position, Circle]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var playerCircle = cm[player];
    entities.forEach((entity) {
      var p = pm[entity];
      var c = cm[entity];

      var distance = playerPos.distanceTo(p);
      var combinedSize = playerCircle.radius + c.radius;

      if (distance < combinedSize) {
        gm.add(entity, circleGroup);

        entity..removeComponent(Collectible)
              ..addComponent(new Friend())
              ..addComponent(new Health(20.0, 20.0))
              ..changedInWorld();
      }
    });
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) != null;
}


class FriendMovementSystem extends EntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Circle> cm;

  FriendMovementSystem() : super(Aspect.getAspectForAllOf([Friend, Position, Circle]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var playerCircle = cm[player];

    var amount = entities.length;

    var count = 0;
    var angleDiff = 0.02;
    entities.forEach((entity) {
      var p = pm[entity];
      var c = cm[entity];

      var distance = playerPos.distanceTo(p);
      var neededDistance = playerCircle.radius + c.radius + 2;

      var ratio = neededDistance / distance;

      var diffX = p.x - playerPos.x;
      var diffY = p.y - playerPos.y;
      var angle = atan2(diffY, diffX) + (count - amount/2) * angleDiff;

      p.x = playerPos.x + cos(angle) * neededDistance;
      p.y = playerPos.y + sin(angle) * neededDistance;

      count++;
    });
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) != null;

}

class HealthColoringSystem extends EntityProcessingSystem {
  Mapper<Health> hm;
  Mapper<Color> cm;

  HealthColoringSystem() : super(Aspect.getAspectForAllOf([Color, Health]));

  @override
  void processEntity(Entity entity) {
    var h = hm[entity];
    var c = cm[entity];

    var ratio = h.value / h.maxHealth;

    var red = ((1-ratio * ratio) * 100).toInt();
    var green = (ratio * ratio * 255).toInt();

    c.fillStyle = '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}00';
  }
}
