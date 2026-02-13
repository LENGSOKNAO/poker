import 'dart:math';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/model/card_model.dart';

class Deck {
  List<CardModel> cards = [];

  Deck() {
    _initializeDeck();
  }

  void _initializeDeck() {
    cards.clear();

    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(CardModel(suit, rank));
      }
    }
  }

  void shuffle() {
    cards.shuffle(Random());
  }

  CardModel drawCard() {
    if (cards.isEmpty) {
      _initializeDeck();
      shuffle();
    }
    return cards.removeLast();
  }

  List<CardModel> drawMutiple(int count) {
    List<CardModel> draw = [];

    for (int i = 0; i < count; i++) {
      if (cards.isEmpty) {
        _initializeDeck();
        shuffle();
      }
      draw.add(cards.removeLast());
    }
    return draw;
  }

  void reset() {
    _initializeDeck();
    shuffle();
  }
}
