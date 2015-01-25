part of shared;

class GameStateUpdateingSystem extends VoidEntitySystem {

  @override
  void processSystem() {
    gameState.score += (world.delta / 1000) * gameState.friendsAlive;
  }
}