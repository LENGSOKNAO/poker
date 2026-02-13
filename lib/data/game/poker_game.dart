import 'dart:math';

import 'package:game_poker/data/model/player.dart';

class PokerGame {
  List<Player> players = [];
  double currentBet = 0;
  int numPlayer = 9;

  PokerGame(
    List<String> playerName,
    double startingChips, {
    this.numPlayer = 9,
  }) {
    for (int i = 0; i < min(playerName.length, numPlayer); i++) {
      players.add(
        Player(name: playerName[i], chips: startingChips, isAI: i > 0),
      );
    }
    setupGame();
  }
  void setupGame() {
    currentBet = 0;
  }
}
