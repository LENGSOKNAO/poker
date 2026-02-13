import 'package:game_poker/data/model/card_model.dart';

class PokerHand {
  final List<CardModel> cards;
  String handRank = '';
  int handValue = 0;
  List<int> kickers = [];

  PokerHand(this.cards) {
    _evaluateHand();
  }

  void _evaluateHand() {}
}
