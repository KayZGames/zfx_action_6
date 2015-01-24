part of shared;

class Circle extends Component {
  double radius;
  Circle(this.radius);
}

class Triangle extends Component {
  double size;
  double orientation;
  Triangle(this.size, this.orientation);
}

class Position extends Component {
  double x, y;
  Position(this.x, this.y);

  double distanceTo(Position other) {
    return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
  }
}

class Velocity extends Component {
  double x, y;
  Velocity(this.x, this.y);
}

class Color extends Component {
  String strokeStyle;
  String fillStyle;
  Color({this.strokeStyle : 'black', this.fillStyle : 'black'});
}

class Health extends Component {
  double value;
  double maxHealth;
  Health(this.value, this.maxHealth);
}

class Heartbeat extends Component {
  double frequency;
  Heartbeat([this.frequency = 60.0]);
}

class CircleDestruction extends Component {}

class Background extends Component {
  int size;
  Background(this.size);
}

class Lifetime extends Component {
  double value;
  Lifetime(this.value);
}

class Collectible extends Component {}
class Friend extends Component {}

class AttentionWhore extends Component {
  double delay;
  AttentionWhore(this.delay);
}

class Message extends Component implements Tweenable {
  static const int OPACITY = 1;
  String message;
  double opacity;
  Message(this.message, [this.opacity = 1.0]);

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    if (tweenType == OPACITY) {
      returnValues[0] = opacity;
      return 1;
    }
    return 0;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    if (tweenType == OPACITY) {
      opacity = newValues[0];
    }
  }
}

class Particle extends Component {}