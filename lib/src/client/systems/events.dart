part of client;


class MouseInputHandlingSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  TagManager tm;
  Point<int> offset = new Point<int>(0, 0);

  CanvasElement canvas;

  MouseInputHandlingSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseMove.listen((event) {
      offset = event.offset;
    });
  }


  @override
  void processSystem() {
    var e = tm.getEntity(playerTag);

    var p = pm[e];

    p.x = offset.x.toDouble();
    p.y = offset.y.toDouble();
  }
}