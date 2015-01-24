part of client;


class CircleRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Circle> circleMapper;
  Mapper<Color> colorMapper;
  Mapper<Heartbeat> hbMapper;

  CanvasRenderingContext2D ctx;

  CircleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Position, Circle, Color, Heartbeat]));


  @override
  void processEntity(Entity entity) {
    var position = pm[entity];
    var circle = circleMapper[entity];
    var color = colorMapper[entity];
    var hb = hbMapper[entity];

    var beat = 60000 / hb.frequency;
    var heartbeatMod = world.time % beat;
    var radius = circle.radius;
    if (heartbeatMod > 0.8 * beat) {
      radius = radius + (1000 * heartbeatMod/beat - 800) * 0.01;
    }

    ctx
        ..beginPath()
        ..fillStyle = color.fillStyle
        ..strokeStyle = color.strokeStyle
        ..arc(position.x, position.y, radius, 0, 2 * PI)
        ..fill()
        ..closePath();
  }
}

class TriangleRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Color> cm;
  Mapper<Orientation> om;

  CanvasRenderingContext2D ctx;

  TriangleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Position, Triangle, Color, Orientation]));


  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var t = tm[entity];
    var c = cm[entity];
    var o = om[entity];

    var angle = o.value;

    ctx
        ..beginPath()
        ..fillStyle = c.fillStyle
        ..strokeStyle = c.strokeStyle
        ..moveTo(p.x + cos(angle) * t.size, p.y + sin(angle) * t.size)
        ..lineTo(p.x + cos(angle + PI * 2 / 3) * t.size, p.y + sin(angle + PI * 2 / 3) * t.size)
        ..lineTo(p.x + cos(angle + PI * 4 / 3) * t.size, p.y + sin(angle + PI * 4 / 3) * t.size)
        ..lineTo(p.x + cos(angle) * t.size, p.y + sin(angle) * t.size)
        ..stroke()
        ..closePath();
  }
}

class HealthRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Health> hm;
  Mapper<Circle> cm;

  CanvasRenderingContext2D ctx;

  HealthRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Health, Position, Circle]));

  @override
  void processEntity(Entity entity) {
    var h = hm[entity];
    var p = pm[entity];
    var c = cm[entity];

    ctx
        ..fillStyle = 'green'
        ..strokeStyle = 'blue'
        ..fillRect(p.x - c.radius / 2, p.y - c.radius * 1.3, c.radius * h.value / 100, c.radius * 0.2)
        ..strokeRect(p.x - c.radius / 2, p.y - c.radius * 1.3, c.radius, c.radius * 0.2);
  }
}

class BackgroundDotRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;
  Mapper<Background> bm;

  CanvasRenderingContext2D ctx;
  BackgroundDotRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Background, Position, Color]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var c = cm[entity];
    var b = bm[entity];

    ctx
        ..fillStyle = c.fillStyle
        ..fillRect(p.x, p.y, b.size, b.size);
  }
}

class MessageRenderingSystem extends EntityProcessingSystem {
  Mapper<Message> mm;
  Mapper<Position> pm;

  CanvasRenderingContext2D ctx;

  MessageRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Message, Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var m = mm[entity];

    var width = ctx.measureText(m.message).width;

    ctx
        ..fillStyle = 'white'
        ..globalAlpha = m.alpha
        ..fillText(m.message, p.x - width / 2, p.y - 20);

    if (m.alpha == 0.0) {
      entity
          ..removeComponent(Message)
          ..changedInWorld();
    }
  }

  @override
  void begin() {
    ctx.save();
  }

  @override
  void end() {
    ctx.restore();
  }
}

class ParticleRenderingSystem extends EntityProcessingSystem {
  Mapper<Color> cm;
  Mapper<Position> pm;
  Mapper<Particle> particleMapper;

  CanvasRenderingContext2D ctx;

  ParticleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Particle, Color, Position]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var c = cm[entity];
    var particle = particleMapper[entity];

    ctx
        ..fillStyle = c.fillStyle
        ..globalAlpha = particle.alpha
        ..fillRect(p.x, p.y, 1, 1);
  }

  @override
  void begin() {
    ctx.save();
  }

  @override
  void end() {
    ctx.restore();
  }
}
