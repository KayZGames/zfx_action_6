part of client;

typedef void UpdateBestValue(int currentValue);

class HighScoreSystem extends VoidEntitySystem {
  TagManager tm;
  Store store;

  @override
  void initialize() {
    store = new Store('zfaxaction6', 'highscore');
    store.open().then((_) {
      updateHighscore();
      updateScreamTime();
    });
  }

  @override
  void processSystem() {
    updateHighscore();
  }

  void updateHighscore() {
    checkAndUpdate('score', gameState.score, (stored) => gameState.highScore = stored);
  }

  void updateScreamTime() {
    checkAndUpdate('longestScream', gameState.inPain, (stored) => gameState.longestScream = stored);
  }

  void checkAndUpdate(String key, double currentValue, UpdateBestValue updateFunction) {
    store.getByKey(key).then((score) {
      if (null == score || score < currentValue) {
        store.save(currentValue.toInt(), key);
      } else {
        updateFunction(score);
      }
    });
  }

  @override
  bool checkProcessing() => tm.getEntity(playerTag) == null;
}
