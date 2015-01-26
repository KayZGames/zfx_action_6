part of client;

class PainAnalysingSystem extends VoidEntitySystem {
  TagManager tm;
  Mapper<Message> mm;
  bool successfulCry = false;

  AnalyserNode node;
  Uint8List byteFrequencyData = new Uint8List(frequencyBinCount);

  PainAnalysingSystem(this.node);

  @override
  void processSystem() {
    node.getByteFrequencyData(byteFrequencyData);

    var player = tm.getEntity(playerTag);
    if (!gameState.rageMode &&
        byteFrequencyData[100] < 30 &&
        byteFrequencyData[5] > 100 &&
        byteFrequencyData[22] < byteFrequencyData[33] &&
        (byteFrequencyData[55] > 40 || byteFrequencyData[80] > byteFrequencyData[57])) {
      if (!successfulCry) {
        successfulCry = true;
        eventBus.fire(new AnalyticsTrackEvent('in pain', 'success'));
      }
      gameState.notInPain = 0.0;
      var before = gameState.inPain ~/ 100.0;
      gameState.inPain += world.delta;
      var after = gameState.inPain ~/ 100.0;
      if (before < after) {
        gameState.painometer += 0.3;
      }
    } else {
      gameState.notInPain += world.delta;
    }
    if (gameState.notInPain > 300.0) {
      gameState.inPain = 0.0;
    }
    Message m;
    if (mm.has(player)) {
      var painMod = gameState.inPain ~/ 100;
      m = mm[player];
      m.message = 'AH!'.split('').map((char) => char * (painMod ~/ 4)).join('');
      m.fontSize = 14 + painMod * 2;
    } else {
      m = new Message('AH!', fontSize: 14);
      player
          ..addComponent(m)
          ..changedInWorld();
      world.processEntityChanges();
    }
    // hacky hack hack
    if (m.message.startsWith('A')) {
      var notInPainMod = gameState.notInPain / 500;
      m.alpha = max(0.0, 1.0 - notInPainMod * notInPainMod * notInPainMod);
    }
  }

  @override
  bool checkProcessing() => node != null && tm.getEntity(playerTag) != null;
}
