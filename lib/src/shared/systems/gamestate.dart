part of shared;

class GameStateUpdateingSystem extends VoidEntitySystem {
  TagManager tm;

  @override
  void processSystem() {
    gameState.score += (world.delta / 1000) * gameState.friendsAlive;
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) != null;
}