part of shared;

class Circle extends Component {
  double radius;
  Circle(this.radius);
}

class Triangle extends Component {
  double size;
  Triangle(this.size);
}

class Thruster extends Component {
  double coreDistance;
  Thruster(this.coreDistance);
}

class Position extends Component {
  double x, y, z;
  Position(this.x, this.y, this.z);

  double distanceTo(Position other) {
    return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
  }
}

class Velocity extends Component {
  double x, y, z;
  Velocity(this.x, this.y, [this.z = 0.0]);

  double get length => sqrt(x * x + y * y + z * z);
}

class Acceleration extends Component implements Tweenable {
  static const VALUE = 1;
  double value;
  Acceleration([this.value = 0.0]);

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    if (tweenType == VALUE) {
      returnValues[0] = value;
      return 1;
    }
    return 0;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    if (tweenType == VALUE) {
      value = newValues[0];
    }
  }
}

class Orientation extends Component implements Tweenable {
  static const VALUE = 1;
  double value;
  Orientation(this.value);

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    if (tweenType == 1) {
      returnValues[0] = value;
      return 1;
    }
    return 0;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    if (tweenType == VALUE) {
      value = newValues[0];
    }
  }
}

class Color extends Component {
  double red;
  double green;
  double blue;
  double alpha;
  Color({this.red: 0.0, this.green: 0.0, this.blue: 0.0, this.alpha: 1.0});
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
  double size;
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

class Message extends Component with Alpha implements Tweenable {
  String message;
  int fontSize;
  Message(this.message, {this.fontSize: 14});
}

class Particle extends Component with Alpha implements Tweenable {}

class Alpha implements Tweenable {
  static const int ALPHA = 1;
  double alpha = 1.0;

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    if (tweenType == ALPHA) {
      returnValues[0] = 1.0;
      return 1;
    }
    return 0;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    if (tweenType == ALPHA) {
      alpha = newValues[0];
    }
  }

}
