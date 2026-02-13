import 'package:game_poker/data/model/card_model.dart';
import 'package:game_poker/data/model/poker_hand.dart';

class Player {
  String name;
  List<CardModel> cards = [];
  double chips;
  bool isAI;
  double currentBet = 0;
  bool isFolded = false;
  bool isAllIn = false;
  String lastAction = '';
  double totalBetThisRound = 0;
  bool isActive = true;

  Player({required this.name, required this.chips, this.isAI = false});

  void reset() {
    cards.clear();
    currentBet = 0;
    totalBetThisRound = 0;
    isFolded = false;
    isAllIn = false;
    isActive = true;
    lastAction = '';
  }

  bool isCheck(double currentBetToMatch) {
    return currentBet >= currentBetToMatch && chips > 0;
  }

  bool isCall(double currentBetToMatch) {
    return currentBet >= (currentBetToMatch - currentBet) && chips > 0;
  }

  bool isRaise(double raiseAmount, double currnetBetMatch) {
    if (chips <= 0) return false;

    double totalNeeded = (raiseAmount - currentBet);

    if (totalNeeded < (currnetBetMatch - currentBet)) {
      totalNeeded = (currnetBetMatch - currentBet) * 2;
    }
    return chips >= totalNeeded;
  }

  void fold() {
    isFolded = true;
    isActive = false;
    lastAction = 'Fold';
  }

  void check() {
    lastAction = 'Check';
  }

  void call(double amount) {
    double amountToCall = amount - currentBet;
    if (amountToCall > chips) {
      amountToCall = chips;
    }
    chips -= amountToCall;
    currentBet = amount;
    totalBetThisRound += amountToCall;
    if (chips <= 0) {
      isAllIn = true;
      lastAction = 'All-In Call \$${amountToCall.toStringAsFixed(0)}';
    } else {
      lastAction = 'Call \$${amountToCall.toStringAsFixed(0)}';
    }
  }

  void raise(double raiseToAmount, double currentBetToMatch) {
    double totalToPut = raiseToAmount - currentBet;
    if (totalToPut > chips) {
      totalToPut = chips;
    }
    chips -= totalToPut;
    currentBet = raiseToAmount;
    totalBetThisRound += totalToPut;
    if (chips <= 0) {
      isAllIn = true;
      lastAction = 'All-In Raise \$${totalToPut.toStringAsFixed(0)}';
    } else {
      lastAction = 'Raise to \$${raiseToAmount.toStringAsFixed(0)}';
    }
  }

  void allIn() {
    if (chips <= 0) {
      double allAmount = chips;
      currentBet += allAmount;
      chips = 0;
      isAllIn = true;
      lastAction = 'All In \$${allAmount.toStringAsFixed(0)}';
    }
  }

  void winPot(double amount) {
    chips += amount;
  }

  PokerHand getBestHand(List<CardModel> communityCards) {
    final allCards = [...cards, ...communityCards];
    return PokerHand(allCards);
  }
}
