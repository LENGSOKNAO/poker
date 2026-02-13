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

  // Get image path for the card
  String get imagePath {
    final rankCode = _getRankCode();
    final suitCode = _getSuitCode();
    return 'assets/cards/${rankCode}_of_$suitCode.png';
  }

  // Get network image URL for the card
  String get imageUrl {
    final rankCode = _getUrlRankCode();
    final suitCode = _getUrlSuitCode();
    return 'https://deckofcardsapi.com/static/img/$rankCode$suitCode.png';
  }

  String _getRankCode() {
    switch (rank) {
      case Rank.ace:
        return 'ace';
      case Rank.king:
        return 'king';
      case Rank.queen:
        return 'queen';
      case Rank.jack:
        return 'jack';
      case Rank.ten:
        return '10';
      case Rank.nine:
        return '9';
      case Rank.eight:
        return '8';
      case Rank.seven:
        return '7';
      case Rank.six:
        return '6';
      case Rank.five:
        return '5';
      case Rank.four:
        return '4';
      case Rank.three:
        return '3';
      case Rank.two:
        return '2';
    }
  }

  String _getSuitCode() {
    switch (suit) {
      case Suit.hearts:
        return 'hearts';
      case Suit.diamonds:
        return 'diamonds';
      case Suit.clubs:
        return 'clubs';
      case Suit.spades:
        return 'spades';
    }
  }

  String _getUrlRankCode() {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.king:
        return 'K';
      case Rank.queen:
        return 'Q';
      case Rank.jack:
        return 'J';
      case Rank.ten:
        return '0';
      default:
        return (rank.index + 2).toString();
    }
  }

  String _getUrlSuitCode() {
    switch (suit) {
      case Suit.hearts:
        return 'H';
      case Suit.diamonds:
        return 'D';
      case Suit.clubs:
        return 'C';
      case Suit.spades:
        return 'S';
    }
  }

  @override
  String toString() => cardName;
}
