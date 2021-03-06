part of shared;


class CircleTriangleCollisionDetectionSystem extends EntitySystem {
  GroupManager groupManager;

  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Circle> cm;
  Mapper<Health> hm;
  Mapper<Heartbeat> hbm;

  var messages = ['HAHA!!', 'PWND!', 'MASSACRE!!!', 'KILL THEM ALL!', 'WE RULE!'];

  CircleTriangleCollisionDetectionSystem() : super(Aspect.getAspectForAllOf([Position, Triangle]));

  @override
  void processEntities(Iterable<Entity> triangles) {
    var circles = groupManager.getEntities(circleGroup);
    circles.forEach((circle) {
      var circlePos = pm[circle];
      var circleCircle = cm[circle];

      triangles.forEach((triangle) {
        var p = pm[triangle];
        var t = tm[triangle];

        var distanceCenter = p.distanceTo(circlePos);
        var combinedSize = circleCircle.radius + t.size;

        if (distanceCenter < combinedSize) {
          if (gameState.rageMode) {
            triangle.deleteFromWorld();
            gameState.painometer -= 0.5;
            gameState.score += 10.0;
            gameState.trianglesKilled += 1;
            var m = new Message(messages[random.nextInt(messages.length)]);
            new Tween.to(m, Alpha.ALPHA, 2.5)
                ..targetValues = [0.0]
                ..easing = TweenEquations.easeInCubic
                ..start(tweenManager);
            circle
                ..addComponent(m)
                ..changedInWorld();

            for (int i = 0; i < t.size * t.size / 2; i++) {
              var distanceToCenter = t.size * random.nextDouble();
              var angleToCenter = 2 * PI * random.nextDouble();
              var zAngle = 2 * PI * random.nextDouble();
              var lifetime = 0.5 + random.nextDouble();
              var particle = new Particle();
              easeParticle(particle, lifetime);

              world.createAndAddEntity(
                  [
                      particle,
                      new Color(green: 0.6 + 0.4 * random.nextDouble(), blue: 0.6 + 0.4 * random.nextDouble()),
                      new Position(p.x + cos(angleToCenter) * distanceToCenter, p.y + sin(angleToCenter) * distanceToCenter, 0.0),
                      new Velocity(
                          cos(angleToCenter) * distanceToCenter / t.size * 500,
                          sin(angleToCenter) * distanceToCenter / t.size * 500,
                          sin(zAngle) * distanceToCenter / t.size * 500),
                      new Lifetime(lifetime)]);
            }

          } else {
            // TODO: do some fancy triangle vs circle collision detection, for now: collide!
            var h = hm[circle];
            var hb = hbm[circle];

            h.value -= 1;
            hb.frequency = 60 + (1 - h.value / h.maxHealth) * 140;
            gameState.painometer += 0.1;

            if (h.value <= 0.0) {
              circle.addComponent(new CircleDestruction());
              circle.changedInWorld();
            }
          }
        }
      });
    });
  }

  @override
  bool checkProcessing() => true;
}

class CircleCollisionSystem extends EntitySystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Circle> cm;
  Mapper<Velocity> vm;

  CircleCollisionSystem() : super(Aspect.getAspectForAllOf([Circle, Friend, Position, Velocity]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var entitiesAsList = entities.toList();
    for (int i = 0; i < entitiesAsList.length - 1; i++) {
      var p1 = pm[entitiesAsList[i]];
      var c1 = cm[entitiesAsList[i]];
      for (int j = i + 1; j < entitiesAsList.length; j++) {
        var p2 = pm[entitiesAsList[j]];
        var c2 = cm[entitiesAsList[j]];
        if (c1.radius + c2.radius > p1.distanceTo(p2)) {
          var v1 = vm[entitiesAsList[i]];
          var v2 = vm[entitiesAsList[j]];

          var dx = p2.x - p1.x;
          var dy = p2.y - p1.y;
          // collision angle
          num phi = atan2(dy, dx);
          num v1i = v1.length;
          num v2i = v2.length;
          num ang1 = atan2(v1.y, v1.x);
          num ang2 = atan2(v2.y, v2.x);

          // transforming velocities in a coordinate system where both circles
          // have an equal y-coordinate thus allowing 1D elastic collision calculations
          num v1xr = v1i * cos(ang1 - phi);
          num v1yr = v1i * sin(ang1 - phi);
          num v2xr = v2i * cos(ang2 - phi);
          num v2yr = v2i * sin(ang2 - phi);
          // calculate momentums
          num mTotal = 2;
          // elastic collision
          num v1fxr = (v1xr + 2 * v2xr - v1xr) / mTotal;
          num v2fxr = (v2xr + 2 * v1xr - v2xr) / mTotal;
          num v1fyr = v1yr;
          num v2fyr = v2yr;
          // transform back to original coordinate system
          v1.x = cos(phi) * v1fxr + cos(phi + PI / 2) * v1fyr * 0.8;
          v1.y = sin(phi) * v1fxr + sin(phi + PI / 2) * v1fyr * 0.8;
          v2.x = cos(phi) * v2fxr + cos(phi + PI / 2) * v2fyr * 0.8;
          v2.y = sin(phi) * v2fxr + sin(phi + PI / 2) * v2fyr * 0.8;
        }
      }
    }
    if (player != null) {
      var p2 = pm[player];
      var c2 = cm[player];
      for (int i = 0; i < entitiesAsList.length; i++) {
        var p1 = pm[entitiesAsList[i]];
        var c1 = cm[entitiesAsList[i]];
        var minDistance = c1.radius + c2.radius;
        if (minDistance > p1.distanceTo(p2)) {
          var v1 = vm[entitiesAsList[i]];
          v1.x = -v1.x * 0.8;
          v1.y = -v1.y * 0.8;
        }
      }
    }
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
      'Those monsters!!!',
      'They killed Kenny!!',
      'Those bastards!',
      'I\'ll get my revenge!',
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
      var zAngle = 2 * PI * random.nextDouble();
      var lifetime = 0.5 + random.nextDouble();
      var particle = new Particle();
      easeParticle(particle, lifetime);

      world.createAndAddEntity(
          [
              particle,
              new Color(red: 0.6 + 0.4 * random.nextDouble()),
              new Position(p.x + cos(angleToCenter) * distanceToCenter, p.y + sin(angleToCenter) * distanceToCenter, 0.0),
              new Velocity(
                  cos(angleToCenter) * distanceToCenter / c.radius * 500,
                  sin(angleToCenter) * distanceToCenter / c.radius * 500,
                  sin(zAngle) * (1.0 - distanceToCenter / c.radius) * 500),
              new Lifetime(lifetime)]);
    }

    gameState.friendsKilled += 1;
    gameState.friendsAlive -= 1;
    gameState.painometer += 5;
    entity.deleteFromWorld();
    processed = true;
  }

  @override
  void end() {
    if (processed) {
      var entities = gm.getEntities(circleGroup);
      entities.forEach((entity) {
        var m = new Message(messages[random.nextInt(messages.length)]);
        new Tween.to(m, Alpha.ALPHA, 2.5)
            ..targetValues = [0.0]
            ..easing = TweenEquations.easeInCubic
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
  static const double pretendMovementY = 100.0;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];

    p.x += v.x * world.delta;
    p.y += (v.y + pretendMovementY) * world.delta;
    p.z += v.z * world.delta;
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
    var o = om[entity];
    var p = pm[entity];
    var t = tm[entity];

    for (int i = 0; i < random.nextInt(10); i++) {
      var lifetime = 0.5 + 0.1 * random.nextDouble();
      var emitAngle = o.value - PI / 4 + random.nextDouble() * PI / 2;
      var zAngle = PI / 4 - random.nextDouble() * PI / 2;
      var particle = new Particle();
      easeParticle(particle, lifetime);

      world.createAndAddEntity(
          [
              particle,
              new Position(p.x - cos(emitAngle) * t.coreDistance, p.y - sin(emitAngle) * t.coreDistance, 0.0),
              new Velocity(
                  -cos(emitAngle) * 100 * random.nextDouble(),
                  -sin(emitAngle) * 100 * random.nextDouble(),
                  sin(zAngle) * 100 * random.nextDouble()),
              new Color(red: 0.8 + 0.2 * random.nextDouble(), green: 0.2 + 0.8 * random.nextDouble()),
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
        new Tween.to(m, Alpha.ALPHA, 2.5)
            ..targetValues = [0.0]
            ..easing = TweenEquations.easeInCubic
            ..start(tweenManager);
        entity
            ..removeComponent(Collectible)
            ..removeComponent(AttentionWhore)
            ..addComponent(new Friend())
            ..addComponent(new Health(20.0, 20.0))
            ..addComponent(m)
            ..addComponent(new Acceleration())
            ..addComponent(new Thruster(c.radius))
            ..changedInWorld();

        gameState.friendsAlive += 1;
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
  Mapper<Acceleration> am;
  Mapper<Orientation> om;
  Mapper<Velocity> vm;

  FriendMovementSystem()
      : super(Aspect.getAspectForAllOf([Friend, Position, Circle, Acceleration, Orientation, Velocity]));

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var playerCircle = cm[player];

    entities.forEach((entity) {
      var p = pm[entity];
      var c = cm[entity];
      var a = am[entity];
      var o = om[entity];

      var distance = playerPos.distanceTo(p);
      var neededDistance = playerCircle.radius + c.radius + 2;

      var missingDistance = distance - neededDistance;

      var diffX = playerPos.x - p.x;
      var diffY = playerPos.y - p.y;
      var angle = atan2(diffY, diffX);

      if (missingDistance <= 25) {
        a.value = 0.0;
      } else {
        if (gameState.rageMode) {
          a.value = sqrt(missingDistance) / 0.01;
        } else {
          a.value = sqrt(missingDistance) / 0.1;
        }
        o.value = angle;
      }
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

    c.red = (1 - ratio * ratio) / 2.5;
    c.green = ratio * ratio;
    c.blue = 0.0;
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
      new Tween.to(m, Alpha.ALPHA, 2.5)
          ..targetValues = [0.0]
          ..easing = TweenEquations.easeInCubic
          ..start(tweenManager);

      entity
          ..removeComponent(AttentionWhore)
          ..addComponent(m)
          ..changedInWorld();

    }
  }
}

class CalmDownSystem extends VoidEntitySystem {
  TagManager tm;
  Mapper<Health> hm;

  @override
  void processSystem() {
    gameState.painometer -= 0.02;
    if (gameState.painometer <= 0.0) {
      gameState.rageMode = false;
      var player = tm.getEntity(playerTag);
      var h = hm[player];
      h.value = h.maxHealth;
    }
  }

  @override
  bool checkProcessing() => gameState.rageMode;
}
