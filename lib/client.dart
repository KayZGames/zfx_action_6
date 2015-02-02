library client;

import 'dart:html' hide Player, Timeline;
import 'dart:web_audio';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:zfx_action_6/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart' hide Triangle, CanvasCleaningSystem;
import 'package:lawndart/lawndart.dart';

//part 'src/client/systems/name.dart';
part 'src/client/systems/highscore.dart';
part 'src/client/systems/audio.dart';
part 'src/client/systems/events.dart';
//part 'src/client/systems/rendering.dart';
part 'src/client/systems/webgl.dart';

class Game extends GameBase {

  MediaStreamAudioSourceNode mediaStreamSource;

  AnalyserNode audioAnalyser;

  Game() : super.noAssets('zfx_action_6', 'canvas', 800, 600, webgl: true) {
    Tween.waypointsLimit = 1;
  }

  void createEntities() {
    TagManager tm = world.getManager(TagManager);
    GroupManager gm = world.getManager(GroupManager);

    var e = addEntity(
        [
            new Circle(20.0),
            new Position(400.0, 300.0),
            new Color(red: 1.0, green: 1.0, blue: 1.0),
            new Heartbeat(),
            new Health(100.0, 100.0)]);
    tm.register(e, playerTag);
    gm.add(e, circleGroup);
  }

  List<EntitySystem> getSystems() {
    return [
        new CircleDestructionSystem(),
        new PainAnalysingSystem(audioAnalyser),

        new GameStateUpdateingSystem(),

        new MouseInputHandlingSystem(canvas),
        new AcccelerationSystem(),
        new ThrusterParticleEmittingSystem(),
        new MovementSystem(),
        new FriendMovementSystem(),
        new CircleTriangleCollisionDetectionSystem(),
        new CircleCollisionSystem(),
        new HealthColoringSystem(),
        new FriendCollectingSystem(),

        new TweeningSystem(),

        new WebGlCanvasCleaningSystem(ctx),

//        new CanvasCleaningSystem(canvas, fillStyle: 'black'),
//        new RageModeRenderer(ctx),
        new BackgroundDotRenderingSystem(ctx),
        new ParticleRenderingSystem(ctx),
        new TriangleRenderingSystem(ctx),
        new CircleRenderingSystem(ctx),
//        new MessageRenderingSystem(ctx),
//        new GameOverRenderingSystem(ctx),
//        new GameStateRenderingSystem(ctx),
        new PainometerRenderingSystem(ctx),
//        new FpsRenderingSystem(ctx),

        new TriangleSpawningSystem(),
        new BackgroundDotSpawner(),
        new FriendSpawner(),
        new LifetimeSystem(),
        new AttentionDelayDecreasingSystem(),

        new CalmDownSystem(),

        new HighScoreSystem(),

        new AnalyticsSystem(AnalyticsSystem.GITHUB, 'zfx_action_6')];
  }

  onInit() {
    world.addManager(new TagManager());
    world.addManager(new GroupManager());

    var audioCtx = new AudioContext();

    return window.navigator.getUserMedia(audio: true, video: false).then((mediaStream) {
      audioAnalyser = audioCtx.createAnalyser();
      audioAnalyser.fftSize = fftSize;
      mediaStreamSource = audioCtx.createMediaStreamSource(mediaStream);
      mediaStreamSource.connectNode(audioAnalyser);
    }).catchError((error) {
    });
  }

  onInitDone() {
    querySelector('canvas').style.cursor = 'none';
    querySelector('#reasonForAudio').style.display = 'none';
    eventBus.fire(new AnalyticsTrackEvent('audio', '${mediaStreamSource != null}'));
  }
}
