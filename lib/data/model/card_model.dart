import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';

class CardModel {
  final Suit suit;
  final Rank rank;

  CardModel(this.suit, this.rank);

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  String get rankText {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.king:
        return 'K';
      case Rank.queen:
        return 'Q';
      case Rank.jack:
        return 'J';
      default:
        return (rank.index + 2).toString();
    }
  }

  Color get color {
    return (suit == Suit.hearts || suit == Suit.diamonds)
        ? Colors.red
        : Colors.black;
  }

  String get cardName => '$rankText$suitSymbol';

  int get value {
    switch (rank) {
      case Rank.ace:
        return 14;
      case Rank.king:
        return 13;
      case Rank.queen:
        return 12;
      case Rank.jack:
        return 11;
      default:
        return rank.index + 2;
    }
  }

  bool get isFaceCard {
    return rank == Rank.jack || rank == Rank.queen || rank == Rank.king;
  }

  String get faceCardSymbol {
    switch (rank) {
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      default:
        return rankText;
    }
  }

  @override
  String toString() => cardName;
}
