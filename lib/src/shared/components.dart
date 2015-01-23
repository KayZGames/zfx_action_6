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
}

class Color extends Component {
  String strokeStyle;
  String fillStyle;
  Color(this.strokeStyle, [this.fillStyle = 'black']);
}

class Health extends Component {
  double value;
  double maxHealth;
  Health(this.value, this.maxHealth);
}

class CircleDestruction extends Component {}