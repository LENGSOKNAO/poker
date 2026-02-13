import 'dart:math';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/model/card_model.dart';
import 'package:game_poker/data/model/deck.dart';
import 'package:game_poker/data/model/player.dart';

class PokerGame {
  List<Player> players = [];
  double currentBet = 0;
  int numPlayer = 9;
  bool isGameover = false;
  BettingRound currentRound = BettingRound.preflop;
  List<CardModel> communityCards = [];
  Deck deck = Deck();
  int dealerIndex = 0;
  int smallBlindIndex = 0;
  double pot = 0;
  int bigBlindIndex = 1;
  int currentPlayerIndex = 0;

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
    deck.reset();

    for (var player in players) {
      player.reset();
    }

    dealerIndex = (dealerIndex + 1) % players.length;
    smallBlindIndex = (dealerIndex + 1) % players.length;
    bigBlindIndex = (dealerIndex + 1) % players.length;
  }

  bool get areAllActivePlayerAllIn {
    List<Player> activePlayers = players.where((p) => p.isFolded).toList();
    if (activePlayers.isEmpty) return false;

    return activePlayers.every((p) => p.isAllIn);
  }
}
