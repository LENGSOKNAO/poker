import 'card_model.dart';
import 'poker_hand.dart';

class Player {
  String name;
  List<CardModel> cards = [];
  double chips;
  double currentBet = 0;
  bool isFolded = false;
  bool isAllIn = false;
  bool isActive = true;
  bool isAI;
  String lastAction = '';
  double totalBetThisRound = 0;

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

  void resetRound() {
    currentBet = 0;
    totalBetThisRound = 0;
  }

  bool canCheck(double currentBetToMatch) {
    return currentBet >= currentBetToMatch && chips > 0;
  }

  bool canCall(double currentBetToMatch) {
    return chips >= (currentBetToMatch - currentBet) && chips > 0;
  }

  bool canRaise(double raiseAmount, double currentBetToMatch) {
    if (chips <= 0) return false;
    double totalNeeded = (raiseAmount - currentBet);
    if (totalNeeded < (currentBetToMatch - currentBet)) {
      totalNeeded = (currentBetToMatch - currentBet) * 2;
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
    if (chips <= 0) return;

    double allInAmount = chips;
    currentBet += allInAmount;
    totalBetThisRound += allInAmount;
    chips = 0;
    isAllIn = true;
    lastAction = 'All-In \$${allInAmount.toStringAsFixed(0)}';
  }

  void winPot(double amount) {
    chips += amount;
  }

  PokerHand getBestHand(List<CardModel> communityCards) {
    final allCards = [...cards, ...communityCards];
    return PokerHand(allCards);
  }
}
