part of client;


class MouseInputHandlingSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  GroupManager gm;
  TagManager tm;
  Point<int> offset = new Point<int>(0, 0);

  CanvasElement canvas;

  MouseInputHandlingSystem(this.canvas);

  @override
  void initialize() {
    canvas.onMouseMove.listen((event) {
      offset = event.offset;
    });
    canvas.onMouseDown.listen((event) {
      if (event.button == 0) {
        if (gameState.painometer >= 100.0) {
          gameState.painometer = 100.0;
          gameState.rageMode = true;
        } else if (tm.getEntity(playerTag) == null) {
          world.deleteAllEntities();
          var e = world.createAndAddEntity(
              [
                  new Circle(20.0),
                  new Position(400.0, 300.0),
                  new Color(fillStyle: '#ffffff'),
                  new Heartbeat(),
                  new Health(100.0, 100.0)]);
          tm.register(e, playerTag);
          gm.add(e, circleGroup);
          gameState = new GameState();
        }
      }
    });
  }


  @override
  void processSystem() {
    var e = tm.getEntity(playerTag);
    var p = pm[e];

    p.x = offset.x.toDouble();
    p.y = offset.y.toDouble();
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) != null;
}
