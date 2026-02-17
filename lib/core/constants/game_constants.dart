import 'package:flutter/cupertino.dart';

class GameConstants {
  static const double smallBlindAmount = 10.0;
  static const double bigBlindAmount = 20.0;
  static const double startingChips = 1000.0;
  static const Duration autoFoldDuration = Duration(seconds: 15);
  static const Duration aiActionDelay = Duration(milliseconds: 1500);
  static const int defaultNumPlayers = 9;
  static const double minimumRaiseMultiplier = 2.0;

  // Buy-in options for Texas Hold'em
  static const List<int> texasHoldemBuyInOptions = [50, 100, 200, 500];

  // Bet options for 1 vs 1
  static const List<int> oneVsOneBetOptions = [50, 100, 200, 500];

  // Tournament options
  static const List<Map<String, dynamic>> tournamentOptions = [
    {'size': 4, 'fee': 50, 'prize': 200, 'points': 25},
    {'size': 8, 'fee': 100, 'prize': 800, 'points': 50},
    {'size': 16, 'fee': 200, 'prize': 3200, 'points': 100},
  ];

  // Poker hand values
  static const Map<String, int> handValues = {
    'Royal Flush': 10,
    'Straight Flush': 9,
    'Four of a Kind': 8,
    'Full House': 7,
    'Flush': 6,
    'Straight': 5,
    'Three of a Kind': 4,
    'Two Pair': 3,
    'One Pair': 2,
    'High Card': 1,
  };

  // Card dimensions
  static const double cardWidth = 80.0;
  static const double cardHeight = 110.0;
  static const double smallCardWidth = 30.0;
  static const double smallCardHeight = 45.0;
  static const double mediumCardWidth = 60.0;
  static const double mediumCardHeight = 85.0;
  static const double largeCardWidth = 80.0;
  static const double largeCardHeight = 110.0;

  // Game colors
  static const int primaryColor = 0xFF0A5C36;
  static const int secondaryColor = 0xFF083022;
  static const int texasHoldemPrimary = 0xFF1E40AF;
  static const int texasHoldemSecondary = 0xFF1E3A8A;
  static const int oneVsOnePrimary = 0xFF6D28D9;
  static const int oneVsOneSecondary = 0xFF4C1D95;
  static const int tournamentPrimary = 0xFFD97706;
  static const int tournamentSecondary = 0xFF92400E;

  // Player AI behavior probabilities
  static const double aiCheckProbability = 0.4;
  static const double aiRaiseProbability = 0.5;
  static const double aiFoldProbability = 0.1;
  static const double aiCallProbability = 0.6;
  static const double aiAllInProbability = 0.1;

  // Default game messages
  static const String welcomeMessage = 'Welcome to Texas Hold\'em!';
  static const String gameStartedMessage = 'Game started! Your turn.';
  static const String aiTurnMessage = 'AI Opponent\'s turn...';
  static const String allInMessage = 'ALL PLAYERS ALL-IN!';
  static const String remainingCardsMessage = 'Remaining cards dealt...';

  // Image
  static const String profileImage = 'https://imgs.search.brave.com/ghpM-ZCsxKPvAejZDv_SuoYRlso27a4zKdtqJf-ZN0o/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90aHlw/aXguY29tL3dwLWNv/bnRlbnQvdXBsb2Fk/cy8yMDIxLzEwL2Fu/aW1lLWF2YXRhci1w/cm9maWxlLXBpY3R1/cmUtdGh5cGl4LTE4/LTcwMHg3MDAuanBn';

}


