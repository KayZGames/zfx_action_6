part of client;

class CanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext gl;

  CanvasCleaningSystem(this.gl);

  @override
  void processSystem() {
    gl
        ..clearColor(0, 0, 0, 1)
        ..clear(RenderingContext.COLOR_BUFFER_BIT);
  }
}
