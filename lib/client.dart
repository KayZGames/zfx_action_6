library client;

import 'dart:html' hide Player, Timeline;

import 'package:zfx_action_6/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart' hide Triangle;

//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {

  Game() : super.noAssets('zfx_action_6', 'canvas', 800, 600);

  void createEntities() {
    TagManager tm = world.getManager(TagManager);
    GroupManager gm = world.getManager(GroupManager);

    var e = addEntity(
        [
            new Circle(20.0),
            new Position(400.0, 300.0),
            new Color('#ffffff', '#ffffff'),
            new Health(100.0, 100.0)]);
    tm.register(e, playerTag);
    gm.add(e, circleGroup);
  }

  List<EntitySystem> getSystems() {
    return [
        new CircleDestructionSystem(),

        new MouseInputHandlingSystem(canvas),
        new MovementSystem(),
        new FriendMovementSystem(),
        new CollisionDetectionSystem(),
        new FriendCollectingSystem(),

        new TweeningSystem(),

        new CanvasCleaningSystem(canvas, fillStyle: 'black'),
        new BackgroundDotRenderingSystem(ctx),
        new TriangleRenderingSystem(ctx),
        new CircleRenderingSystem(ctx),
        new HealthRenderingSystem(ctx),
        new FpsRenderingSystem(ctx),

        new TriangleSpawningSystem(),
        new BackgroundDotSpawner(),
        new FriendSpawner(),
        new LifetimeSystem(),

        new AnalyticsSystem(AnalyticsSystem.GITHUB, 'zfx_action_6')];
  }

  onInit() {
    world.addManager(new TagManager());
    world.addManager(new GroupManager());
  }
}
