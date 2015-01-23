part of client;


class CircleRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Circle> circleMapper;
  Mapper<Color> colorMapper;

  CanvasRenderingContext2D ctx;

  CircleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Position, Circle, Color]));


  @override
  void processEntity(Entity entity) {
    var position = pm[entity];
    var circle = circleMapper[entity];
    var color = colorMapper[entity];

    ctx..beginPath()
       ..fillStyle = color.fillStyle
       ..strokeStyle = color.strokeStyle
       ..arc(position.x, position.y, circle.radius, 0, 2 * PI)
       ..stroke()
       ..fill()
       ..closePath();
  }
}

class TriangleRenderingSystem extends EntityProcessingSystem {
  Mapper<Position> pm;
  Mapper<Triangle> tm;
  Mapper<Color> cm;

  CanvasRenderingContext2D ctx;

  TriangleRenderingSystem(this.ctx) : super(Aspect.getAspectForAllOf([Position, Triangle, Color]));


  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var t = tm[entity];
    var c = cm[entity];

    var o = t.orientation;

    ctx..beginPath()
        ..fillStyle = c.fillStyle
        ..strokeStyle = c.strokeStyle
        ..moveTo(p.x + cos(o) * t.size, p.y + sin(o) * t.size)
        ..lineTo(p.x + cos(o + PI * 2/3) * t.size, p.y + sin(o + PI * 2/3) * t.size)
        ..lineTo(p.x + cos(o + PI * 4/3) * t.size, p.y + sin(o + PI * 4/3) * t.size)
        ..lineTo(p.x + cos(o) * t.size, p.y + sin(o) * t.size)
        ..stroke()
        ..closePath();
  }
}
