library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart' hide Triangle;

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/gamestate.dart';
part 'src/shared/systems/logic.dart';
part 'src/shared/systems/spawner.dart';

const String playerTag = 'player';
const String cameraTag = 'camera';
const String circleGroup = 'circles';

const int fftSize = 512;
const int frequencyBinCount = fftSize ~/ 2;

GameState gameState = new GameState();

class GameState {
  double score = 0.0;
  int friendsAlive = 0;
  int friendsKilled = 0;
  int trianglesKilled = 0;
  double inPain = 0.0;
  double notInPain = 0.0;
  num painometer = 0.0;
  bool rageMode = false;
  int highScore = 0;
  int longestScream = 0;

  double get rageMod {
    var mod = 1 - gameState.painometer / 100;
    return (1 - mod * mod * mod * mod);
  }
}

void easeParticle(Particle particle, double lifetime) {
  new Tween.to(particle, Alpha.ALPHA, lifetime)
      ..targetValues = [0.0]
      ..easing = TweenEquations.easeInQuart
      ..start(tweenManager);
}

String randomBrightColor() => '#${randomBrightColorFragment()}${randomBrightColorFragment()}${randomBrightColorFragment()}';
String randomBrightColorFragment() => (150 + random.nextInt(105)).toInt().toRadixString(16);
