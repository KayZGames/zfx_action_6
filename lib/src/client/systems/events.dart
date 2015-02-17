part of client;


class MouseInputHandlingSystem extends VoidEntitySystem {
  Mapper<Position> pm;
  GroupManager gm;
  TagManager tm;
  HighScoreSystem hss;
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
          eventBus.fire(new AnalyticsTrackEvent('Rage Mode', ''), sync: false);
        } else if (tm.getEntity(playerTag) == null) {
          world.deleteAllEntities();
          createInitialEntities(world);
          gameState = new GameState();
          hss.updateHighscore();
          eventBus.fire(new AnalyticsTrackEvent('Restart Game', ''), sync: false);
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

class CameraSwitchingSystem extends VoidEntitySystem {
  TagManager tm;
  Mapper<Camera> cm;
  RadioButtonInputElement input3d = querySelector('#threed');

  @override
  void processSystem() {
    var cameraEntity = tm.getEntity(cameraTag);
    var camera = cm[cameraEntity];
    if (input3d.checked) {
      var old = camera.three;
      camera.three += (1.0 - old) * 0.0001;
    } else {
      camera.three *= 0.92;
    }
  }
}
