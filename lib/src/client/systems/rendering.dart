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
    var mod = 0.01;
    var fillStyle = color.fillStyle;
    if (gameState.rageMode) {
      // hacky hacky hack
      if (fillStyle != 'white') {
        beat = 250;
        mod = 0.025;
        fillStyle = '#8A0707';
      }
    }
    var heartbeatMod = world.time % beat;
    var radius = circle.radius;
    if (heartbeatMod > 0.8 * beat) {
      radius = radius + (1000 * heartbeatMod / beat - 800) * mod;
    }

    ctx
        ..beginPath()
        ..fillStyle = fillStyle
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
  double beatMod = 1.0;

  CanvasRenderingContext2D ctx;

  TriangleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Position, Triangle, Color, Orientation]));

  @override
  void begin() {
    var mod = sin(world.time / 140.0);
    beatMod = 1 + (mod * mod * mod * mod) / 2;
  }

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var t = tm[entity];
    var c = cm[entity];
    var o = om[entity];

    var angle = o.value;

    var size = t.size * beatMod;
    ctx
        ..beginPath()
        ..lineWidth = 2
        ..strokeStyle = c.strokeStyle
        ..moveTo(p.x + cos(angle) * size, p.y + sin(angle) * size)
        ..lineTo(p.x + cos(angle + PI * 2 / 3) * size, p.y + sin(angle + PI * 2 / 3) * size)
        ..lineTo(p.x + cos(angle + PI * 4 / 3) * size, p.y + sin(angle + PI * 4 / 3) * size)
        ..lineTo(p.x + cos(angle) * size, p.y + sin(angle) * size)
        ..stroke()
        ..closePath();
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
  Mapper<Circle> cm;

  CanvasRenderingContext2D ctx;

  MessageRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Message, Position, Circle]));

  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var m = mm[entity];
    var c = cm[entity];

    ctx.font = '${m.fontSize}px Verdana';
    var width = ctx.measureText(m.message).width;
    ctx
        ..fillStyle = 'white'
        ..globalAlpha = m.alpha
        ..fillText(m.message, p.x - width / 2, p.y - c.radius - m.fontSize - 10);

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

class GameStateRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;

  GameStateRenderingSystem(this.ctx);

  @override
  void begin() {
    ctx
        ..save()
        ..lineWidth = 1
        ..fillStyle = 'white'
        ..strokeStyle = 'cyan';
  }

  @override
  void processSystem() {
    var score = gameState.score.toInt();
    var highScore = gameState.highScore;
    var scoreWidth = ctx.measureText(score.toString()).width.toInt();
    var highScoreWidth = ctx.measureText(highScore.toString()).width.toInt();
    var screamTimeWidth = ctx.measureText(gameState.longestScream.toString()).width.toInt();
    var currentScreamTimeWidth = ctx.measureText(gameState.inPain.toInt().toString()).width.toInt();
    var width = max(scoreWidth, max(highScoreWidth, max(screamTimeWidth, currentScreamTimeWidth)));

    if (gameState.longestScream > 0) {
      printStateLeft('Longest Scream (ms)', gameState.longestScream, width, 0);
    }
    printStateLeft('HighScore', highScore, width, 20);

    printStateRight('Score', score, width, 0);
    printStateRight('Current Scream (ms)', gameState.inPain.toInt(), width, 20);
    if (gameState.friendsAlive > 0 || gameState.friendsKilled > 0) {
      printStateRight('Friends', gameState.friendsAlive, width, 40);
    }
    if (gameState.friendsKilled > 0) {
      printStateRight('Killed Friends', gameState.friendsKilled, width, 60);
    }
    if (gameState.trianglesKilled > 0) {
      printStateRight('Destroyed Triangles', gameState.trianglesKilled, width, 80);
    }

    renderPainometer();
  }

  void renderPainometer() {
    var gradient = ctx.createLinearGradient(0, 0, 600, 1);
    gradient
        ..addColorStop(0, 'green')
        ..addColorStop(1, 'red');
    var painometer = min(600, 600 * gameState.painometer / 100);
    var label = 'PAIN-O-METER';
    if (gameState.painometer >= 100.0) {
      ctx.lineWidth = 1 + (1 + sin(world.time / 100)) * 2;
      ctx
          ..strokeStyle = '#8A0707'
          ..strokeRect(0, 0, 800, 600);
      label = 'Left click to enter RAGE MODE';
    }
    var width = ctx.measureText(label).width;
    ctx
        ..fillStyle = gradient
        ..strokeStyle = 'cyan'
        ..fillRect(100, 570, painometer, 20)
        ..strokeRect(100, 570, 600, 20)
        ..fillStyle = 'white'
        ..strokeText(label, 400 - width / 2, 572)
        ..fillText(label, 400 - width / 2, 572);
  }

  void printStateLeft(String label, int value, int scoreWidth, int y) =>
      printState(label, value, scoreWidth, scoreWidth + 150, y);
  void printStateRight(String label, int value, int scoreWidth, int y) => printState(label, value, scoreWidth, 770, y);

  void printState(String label, int value, int scoreWidth, int x, int y) {
    var width = ctx.measureText(value.toString()).width;
    var labelWidth = ctx.measureText(label).width;
    ctx
        ..strokeText('$label:', x - labelWidth - scoreWidth, y)
        ..strokeText('$value', x + 20 - width, y)
        ..fillText('$label:', x - labelWidth - scoreWidth, y)
        ..fillText('$value', x + 20 - width, y);
  }

  @override
  void end() {
    ctx.restore();
  }
}

class RageModeRenderer extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;

  RageModeRenderer(this.ctx);

  @override
  void processSystem() {
    var mod = gameState.rageMod;
    ctx
        ..save()
        ..strokeStyle = '#202020'
        ..lineWidth = 5
        ..font = '200px Verdana';
    var rageWidth = ctx.measureText('RAGE').width;
    var modeWidth = ctx.measureText('MODE').width;
    ctx
        ..globalAlpha = 0.4 * mod
        ..strokeText('RAGE', 400 - rageWidth / 2, 80)
        ..strokeText('MODE', 400 - modeWidth / 2, 250)
        ..globalAlpha = 0.7 * mod
        ..fillStyle = '#8A0707'
        ..fillRect(0, 0, 800, 600)
        ..restore();
  }

  @override
  bool checkProcessing() => gameState.rageMode;
}

class GameOverRenderingSystem extends VoidEntitySystem {
  TagManager tm;

  CanvasRenderingContext2D ctx;

  GameOverRenderingSystem(this.ctx);

  @override
  void processSystem() {
    var score = 'Final Score: ${gameState.score.toInt()}';
    var restart = 'click to try again';
    ctx
        ..save()
        ..strokeStyle = '#202020'
        ..lineWidth = 5
        ..font = '200px Verdana';
    var gameWidth = ctx.measureText('GAME').width;
    var overWidth = ctx.measureText('OVER').width;
    ctx
        ..strokeText('GAME', 400 - gameWidth / 2, 30)
        ..strokeText('OVER', 400 - overWidth / 2, 200)
        ..font = '40px Verdana';
    var scoreWidth = ctx.measureText(score).width;
    ctx
        ..lineWidth = 2
        ..fillStyle = 'grey'
        ..strokeText(score, 400 - scoreWidth / 2, 430)
        ..fillText(score, 400 - scoreWidth / 2, 430)
        ..lineWidth = 1
        ..font = '20px Verdana';
    var restartWidth = ctx.measureText(restart).width;
    ctx
        ..strokeText(restart, 400 - restartWidth / 2, 470)
        ..fillText(restart, 400 - restartWidth / 2, 470)
        ..restore();
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) == null;
}
