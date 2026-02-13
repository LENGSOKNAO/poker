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

  // ========================================
  // ALL 52 CARD NETWORK LINKS STORED HERE
  // ========================================
  static const Map<String, String> _cardImageUrls = {
    // Spades ♠
    'AS': 'https://deckofcardsapi.com/static/img/AS.svg',
    '2S': 'https://deckofcardsapi.com/static/img/2S.svg',
    '3S': 'https://deckofcardsapi.com/static/img/3S.svg',
    '4S': 'https://deckofcardsapi.com/static/img/4S.svg',
    '5S': 'https://deckofcardsapi.com/static/img/5S.svg',
    '6S': 'https://deckofcardsapi.com/static/img/6S.svg',
    '7S': 'https://deckofcardsapi.com/static/img/7S.svg',
    '8S': 'https://deckofcardsapi.com/static/img/8S.svg',
    '9S': 'https://deckofcardsapi.com/static/img/9S.svg',
    '0S': 'https://deckofcardsapi.com/static/img/0S.svg', // 10 of Spades
    'JS': 'https://deckofcardsapi.com/static/img/JS.svg',
    'QS': 'https://deckofcardsapi.com/static/img/QS.svg',
    'KS': 'https://deckofcardsapi.com/static/img/KS.svg',

    // Hearts ♥
    'AH': 'https://deckofcardsapi.com/static/img/AH.svg',
    '2H': 'https://deckofcardsapi.com/static/img/2H.svg',
    '3H': 'https://deckofcardsapi.com/static/img/3H.svg',
    '4H': 'https://deckofcardsapi.com/static/img/4H.svg',
    '5H': 'https://deckofcardsapi.com/static/img/5H.svg',
    '6H': 'https://deckofcardsapi.com/static/img/6H.svg',
    '7H': 'https://deckofcardsapi.com/static/img/7H.svg',
    '8H': 'https://deckofcardsapi.com/static/img/8H.svg',
    '9H': 'https://deckofcardsapi.com/static/img/9H.svg',
    '0H': 'https://deckofcardsapi.com/static/img/0H.svg',
    'JH': 'https://deckofcardsapi.com/static/img/JH.svg',
    'QH': 'https://deckofcardsapi.com/static/img/QH.svg',
    'KH': 'https://deckofcardsapi.com/static/img/KH.svg',

    // Diamonds ♦
    'AD': 'https://deckofcardsapi.com/static/img/AD.svg',
    '2D': 'https://deckofcardsapi.com/static/img/2D.svg',
    '3D': 'https://deckofcardsapi.com/static/img/3D.svg',
    '4D': 'https://deckofcardsapi.com/static/img/4D.svg',
    '5D': 'https://deckofcardsapi.com/static/img/5D.svg',
    '6D': 'https://deckofcardsapi.com/static/img/6D.svg',
    '7D': 'https://deckofcardsapi.com/static/img/7D.svg',
    '8D': 'https://deckofcardsapi.com/static/img/8D.svg',
    '9D': 'https://deckofcardsapi.com/static/img/9D.svg',
    '0D': 'https://deckofcardsapi.com/static/img/0D.svg',
    'JD': 'https://deckofcardsapi.com/static/img/JD.svg',
    'QD': 'https://deckofcardsapi.com/static/img/QD.svg',
    'KD': 'https://deckofcardsapi.com/static/img/KD.svg',

    // Clubs ♣
    'AC': 'https://deckofcardsapi.com/static/img/AC.svg',
    '2C': 'https://deckofcardsapi.com/static/img/2C.svg',
    '3C': 'https://deckofcardsapi.com/static/img/3C.svg',
    '4C': 'https://deckofcardsapi.com/static/img/4C.svg',
    '5C': 'https://deckofcardsapi.com/static/img/5C.svg',
    '6C': 'https://deckofcardsapi.com/static/img/6C.svg',
    '7C': 'https://deckofcardsapi.com/static/img/7C.svg',
    '8C': 'https://deckofcardsapi.com/static/img/8C.svg',
    '9C': 'https://deckofcardsapi.com/static/img/9C.svg',
    '0C': 'https://deckofcardsapi.com/static/img/0C.svg',
    'JC': 'https://deckofcardsapi.com/static/img/JC.svg',
    'QC': 'https://deckofcardsapi.com/static/img/QC.svg',
    'KC': 'https://deckofcardsapi.com/static/img/KC.svg',
  };

  static const String backImageUrl =
      'https://deckofcardsapi.com/static/img/back.png';

  // Get network image URL using the stored map (fast lookup)
  String get imageUrl {
    final rankCode = _getUrlRankCode();
    final suitCode = _getUrlSuitCode();
    final key = '$rankCode$suitCode';

    // Use stored link if exists, fallback to dynamic construction
    return _cardImageUrls[key] ??
        'https://deckofcardsapi.com/static/img/$key.svg';
  }

  // Get image path for local assets (unchanged)
  String get imagePath {
    final rankCode = _getRankCode();
    final suitCode = _getSuitCode();
    return 'assets/cards/${rankCode}_of_$suitCode.png';
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
