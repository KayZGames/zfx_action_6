part of client;

class HighScoreSystem extends VoidEntitySystem {
  TagManager tm;
  Store store;

  @override
  void initialize() {
    store = new Store('zfaxaction6', 'highscore');
    store.open().then((_) {
      updateHighscore();
    });
  }

  @override
  void processSystem() {
    updateHighscore();
  }

  void updateHighscore() {
    store.getByKey('score').then((score) {
      if (null == score || score < gameState.score) {
        store.save(gameState.score.toInt(), 'score');
      } else {
        gameState.highScore = score;
      }
    });
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) == null;
}
