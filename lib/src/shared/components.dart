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