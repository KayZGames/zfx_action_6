part of shared;


class CollisionDetectionSystem extends EntitySystem {
  GroupManager groupManager;

  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Circle> cm;
  Mapper<Health> hm;
  Mapper<Heartbeat> hbm;

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
          var hb = hbm[circle];

          h.value -= 1;
          hb.frequency = 60 + (1 - h.value / h.maxHealth) * 140;

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
  GroupManager gm;
  Mapper<Position> pm;
  Mapper<Circle> cm;

  var processed = false;
  var messages = [
      'Noooo!!!!',
      'You monster!!!',
      'You killed Kenny!!',
      'Bastard!',
      'He was my best friend :\'((',
      'Whhhyyyy?!?'];

  CircleDestructionSystem() : super(Aspect.getAspectForAllOf([Position, Circle, CircleDestruction]));

  @override
  void processEntity(Entity entity) {
    var c = cm[entity];
    var p = pm[entity];

    for (int i = 0; i < PI * c.radius * c.radius; i++) {
      var distanceToCenter = c.radius * random.nextDouble();
      var angleToCenter = 2 * PI * random.nextDouble();
      var lifetime = 500.0 + random.nextInt(1000);
      var particle = new Particle();
      easeParticle(particle, lifetime);

      world.createAndAddEntity(
          [
              particle,
              new Color(fillStyle: randomBrightColor()),
              new Position(p.x + cos(angleToCenter) * distanceToCenter, p.y + sin(angleToCenter) * distanceToCenter),
              new Velocity(cos(angleToCenter) * distanceToCenter / c.radius / 2, sin(angleToCenter) * distanceToCenter / c.radius / 2),
              new Lifetime(lifetime)]);
    }

    entity.deleteFromWorld();
    processed = true;
  }

  @override
  void end() {
    if (processed) {
      var entities = gm.getEntities(circleGroup);
      entities.forEach((entity) {
        var m = new Message(messages[random.nextInt(messages.length)]);
        new Tween.to(m, Alpha.ALPHA, 2500.0)
            ..targetValues = [0.0]
            ..easing = TweenEquations.easeInOutCubic
            ..start(tweenManager);
        entity
            ..addComponent(m)
            ..changedInWorld();
      });
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

class AcccelerationSystem extends EntityProcessingSystem {
  Mapper<Velocity> vm;
  Mapper<Acceleration> am;
  Mapper<Orientation> om;

  AcccelerationSystem() : super(Aspect.getAspectForAllOf([Velocity, Acceleration, Orientation]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var v = vm[entity];
    var o = om[entity];

    v.x += a.value * cos(o.value) * world.delta;
    v.y += a.value * sin(o.value) * world.delta;
  }
}

class ThrusterParticleEmittingSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Orientation> om;
  Mapper<Position> pm;
  Mapper<Thruster> tm;

  ThrusterParticleEmittingSystem() : super(Aspect.getAspectForAllOf([Acceleration, Orientation, Position, Thruster]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var o = om[entity];
    var p = pm[entity];
    var t = tm[entity];

    for (int i = 0; i < (a.value * 1000 + 1) * 2.5; i++) {
      var lifetime = 500.0 + random.nextInt(100);
      var emitAngle = o.value - PI / 4 + random.nextDouble() * PI / 2;
      var particle = new Particle();
      easeParticle(particle, lifetime);

      world.createAndAddEntity(
          [
              particle,
              new Position(p.x - cos(emitAngle) * t.coreDistance, p.y - sin(emitAngle) * t.coreDistance),
              new Velocity(-cos(emitAngle) * 0.2 * random.nextDouble(), -sin(emitAngle) * 0.2 * random.nextDouble()),
              new Color(
                  fillStyle:
                      '#${(200 + random.nextInt(50)).toInt().toRadixString(16)}${(50 + random.nextInt(200)).toInt().toRadixString(16)}00'),
              new Lifetime(lifetime)]);
    }
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

  var messages = ['Yay!', 'Thank you!!', 'Hey buddy!!', 'I\'m soo happy!', 'Oh joy!'];

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
        var m = new Message(messages[random.nextInt(messages.length)]);
        new Tween.to(m, Alpha.ALPHA, 2500.0)
            ..targetValues = [0.0]
            ..easing = TweenEquations.easeInOutCubic
            ..start(tweenManager);
        entity
            ..removeComponent(Collectible)
            ..removeComponent(AttentionWhore)
            ..addComponent(new Friend())
            ..addComponent(new Health(20.0, 20.0))
            ..addComponent(m)
            ..changedInWorld();
      }
    });
  }

  @override
  void end() {
    world.processEntityChanges();
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
      var angle = atan2(diffY, diffX) + (count - amount / 2) * angleDiff;

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

    var red = ((1 - ratio * ratio) * 100).toInt();
    var green = (ratio * ratio * 255).toInt();

    c.fillStyle = '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}00';
  }
}

class AttentionDelayDecreasingSystem extends EntityProcessingSystem {
  Mapper<AttentionWhore> am;
  var messages = [
      'Hello?',
      'I\'m so lonely...',
      'Help!!',
      'Please save me...',
      'I wanna be your friend.',
      'Greetings stranger!',
      'Is anybody out there?'];

  AttentionDelayDecreasingSystem() : super(Aspect.getAspectForAllOf([AttentionWhore]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    a.delay -= world.delta;
    if (a.delay <= 0.0) {
      var m = new Message(messages[random.nextInt(messages.length)]);
      new Tween.to(m, Alpha.ALPHA, 2500.0)
          ..targetValues = [0.0]
          ..easing = TweenEquations.easeInOutCubic
          ..start(tweenManager);

      entity
          ..removeComponent(AttentionWhore)
          ..addComponent(m)
          ..changedInWorld();

    }
  }
}
