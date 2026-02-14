import 'card_model.dart';

class PokerHand {
  final List<CardModel> cards;
  String handRank = '';
  int handValue = 0;
  List<int> kickers = [];

  PokerHand(this.cards) {
    _evaluateHand();
  }

  void _evaluateHand() {
    final bestFive = _getBestFiveCardHand();
    final sortedCards = List<CardModel>.from(bestFive);
    sortedCards.sort((a, b) => b.value.compareTo(a.value));

    if (_isRoyalFlush(sortedCards)) {
      handRank = 'Royal Flush';
      handValue = 10;
      kickers = sortedCards.map((c) => c.value).toList();
    } else if (_isStraightFlush(sortedCards)) {
      handRank = 'Straight Flush';
      handValue = 9;
      kickers = [sortedCards[0].value];
    } else if (_isFourOfAKind(sortedCards)) {
      handRank = 'Four of a Kind';
      handValue = 8;
      _setKickersForFourOfAKind(sortedCards);
    } else if (_isFullHouse(sortedCards)) {
      handRank = 'Full House';
      handValue = 7;
      _setKickersForFullHouse(sortedCards);
    } else if (_isFlush(sortedCards)) {
      handRank = 'Flush';
      handValue = 6;
      kickers = sortedCards.map((c) => c.value).toList();
    } else if (_isStraight(sortedCards)) {
      handRank = 'Straight';
      handValue = 5;
      kickers = [sortedCards[0].value];
    } else if (_isThreeOfAKind(sortedCards)) {
      handRank = 'Three of a Kind';
      handValue = 4;
      _setKickersForThreeOfAKind(sortedCards);
    } else if (_isTwoPair(sortedCards)) {
      handRank = 'Two Pair';
      handValue = 3;
      _setKickersForTwoPair(sortedCards);
    } else if (_isOnePair(sortedCards)) {
      handRank = 'One Pair';
      handValue = 2;
      _setKickersForOnePair(sortedCards);
    } else {
      handRank = 'High Card';
      handValue = 1;
      kickers = sortedCards.map((c) => c.value).toList();
    }
  }

  List<CardModel> _getBestFiveCardHand() {
    if (cards.length <= 5) return cards;

    List<List<CardModel>> combinations = [];
    _generateCombinations(cards, 5, 0, [], combinations);

    combinations.sort((a, b) {
      final handA = PokerHand(a);
      final handB = PokerHand(b);
      return _compareHands(handB, handA);
    });

    return combinations.isNotEmpty ? combinations.first : cards.sublist(0, 5);
  }

  void _generateCombinations(
    List<CardModel> cards,
    int k,
    int start,
    List<CardModel> current,
    List<List<CardModel>> result,
  ) {
    if (current.length == k) {
      result.add(List.from(current));
      return;
    }

    for (int i = start; i < cards.length; i++) {
      current.add(cards[i]);
      _generateCombinations(cards, k, i + 1, current, result);
      current.removeLast();
    }
  }

  int _compareHands(PokerHand handA, PokerHand handB) {
    if (handA.handValue != handB.handValue) {
      return handA.handValue.compareTo(handB.handValue);
    }

    for (int i = 0; i < handA.kickers.length; i++) {
      if (handA.kickers[i] != handB.kickers[i]) {
        return handA.kickers[i].compareTo(handB.kickers[i]);
      }
    }

    return 0;
  }

  void _setKickersForFourOfAKind(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }

    int fourValue = valueCount.entries.firstWhere((e) => e.value == 4).key;
    int kicker = valueCount.entries.firstWhere((e) => e.value == 1).key;

    kickers = [fourValue, fourValue, fourValue, fourValue, kicker];
  }

  void _setKickersForFullHouse(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }

    int threeValue = valueCount.entries.firstWhere((e) => e.value == 3).key;
    int twoValue = valueCount.entries.firstWhere((e) => e.value == 2).key;

    kickers = [threeValue, threeValue, threeValue, twoValue, twoValue];
  }

  void _setKickersForThreeOfAKind(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }

    int threeValue = valueCount.entries.firstWhere((e) => e.value == 3).key;
    List<int> otherValues = valueCount.entries
        .where((e) => e.value != 3)
        .map((e) => e.key)
        .toList();
    otherValues.sort((a, b) => b.compareTo(a));

    kickers = [threeValue, threeValue, threeValue, ...otherValues.take(2)];
  }

  void _setKickersForTwoPair(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }

    List<int> pairValues = valueCount.entries
        .where((e) => e.value == 2)
        .map((e) => e.key)
        .toList();
    pairValues.sort((a, b) => b.compareTo(a));

    int kicker = valueCount.entries.firstWhere((e) => e.value == 1).key;

    kickers = [
      pairValues[0],
      pairValues[0],
      pairValues[1],
      pairValues[1],
      kicker,
    ];
  }

  void _setKickersForOnePair(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }

    int pairValue = valueCount.entries.firstWhere((e) => e.value == 2).key;
    List<int> otherValues = valueCount.entries
        .where((e) => e.value != 2)
        .map((e) => e.key)
        .toList();
    otherValues.sort((a, b) => b.compareTo(a));

    kickers = [pairValue, pairValue, ...otherValues.take(3)];
  }

  bool _isRoyalFlush(List<CardModel> cards) {
    return _isStraightFlush(cards) && cards[0].value == 14;
  }

  bool _isStraightFlush(List<CardModel> cards) {
    return _isFlush(cards) && _isStraight(cards);
  }

  bool _isFourOfAKind(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }
    return valueCount.values.any((count) => count == 4);
  }

  bool _isFullHouse(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }
    final values = valueCount.values.toList();
    return values.contains(3) && values.contains(2);
  }

  bool _isFlush(List<CardModel> cards) {
    final firstSuit = cards[0].suit;
    return cards.every((card) => card.suit == firstSuit);
  }

  bool _isStraight(List<CardModel> cards) {
    final values = cards.map((c) => c.value).toSet().toList();
    if (values.length < 5) return false;
    values.sort((a, b) => b.compareTo(a));

    // Check for A-2-3-4-5 straight (wheel)
    if (values.contains(14) &&
        values.contains(5) &&
        values.contains(4) &&
        values.contains(3) &&
        values.contains(2)) {
      return true;
    }

    // Check for normal straight
    for (int i = 0; i <= values.length - 5; i++) {
      bool isStraight = true;
      for (int j = i; j < i + 4; j++) {
        if (values[j] != values[j + 1] + 1) {
          isStraight = false;
          break;
        }
      }
      if (isStraight) return true;
    }
    return false;
  }

  bool _isThreeOfAKind(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }
    return valueCount.values.any((count) => count == 3);
  }

  bool _isTwoPair(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }
    final pairs = valueCount.values.where((count) => count == 2).length;
    return pairs == 2;
  }

  bool _isOnePair(List<CardModel> cards) {
    final valueCount = <int, int>{};
    for (var card in cards) {
      valueCount[card.value] = (valueCount[card.value] ?? 0) + 1;
    }
    return valueCount.values.any((count) => count == 2);
  }
}
