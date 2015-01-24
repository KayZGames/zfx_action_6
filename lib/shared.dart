library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart' hide Triangle;

part 'src/shared/components.dart';

//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';
part 'src/shared/systems/spawner.dart';

const String playerTag = 'player';
const String circleGroup = 'circles';



void easeParticle(Particle particle, double lifetime) {
  new Tween.to(particle, Alpha.ALPHA, lifetime)
      ..targetValues = [0.0]
      ..easing = TweenEquations.easeInQuart
      ..start(tweenManager);
}

String randomBrightColor() => '#${randomBrightColorFragment()}${randomBrightColorFragment()}${randomBrightColorFragment()}';
String randomBrightColorFragment() => (150 + random.nextInt(105)).toInt().toRadixString(16);
