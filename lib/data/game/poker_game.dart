import 'dart:math';
import 'package:game_poker/core/constants/game_constants.dart';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/model/card_model.dart';
import 'package:game_poker/data/model/deck.dart';
import 'package:game_poker/data/model/player.dart';
import 'package:game_poker/data/model/poker_hand.dart';

class PokerGame {
  List<Player> players = [];
  List<CardModel> communityCards = [];
  Deck deck = Deck();
  double pot = 0;
  double currentBet = 0;
  int currentPlayerIndex = 0;
  BettingRound currentRound = BettingRound.preflop;
  bool isGameOver = false;
  Player? winner;
  List<Player> winners = [];
  int smallBlindIndex = 0;
  int bigBlindIndex = 1;
  double smallBlindAmount = GameConstants.smallBlindAmount;
  double bigBlindAmount = GameConstants.bigBlindAmount;
  bool blindsPosted = false;
  int actionsThisRound = 0;
  int dealerIndex = 0;
  int numPlayers = 9;
  List<double> sidePots = [];
  List<List<Player>> sidePotPlayers = [];

  PokerGame(
    List<String> playerNames,
    double startingChips, {
    this.numPlayers = 9,
  }) {
    for (int i = 0; i < min(playerNames.length, numPlayers); i++) {
      players.add(
        Player(name: playerNames[i], chips: startingChips, isAI: i > 0),
      );
    }
    setupGame();
  }

  void setupGame() {
    deck.reset();
    communityCards.clear();
    pot = 0;
    currentBet = 0;
    currentRound = BettingRound.preflop;
    isGameOver = false;
    winner = null;
    winners.clear();
    actionsThisRound = 0;
    blindsPosted = false;
    sidePots.clear();
    sidePotPlayers.clear();

    for (var player in players) {
      player.reset();
    }

    dealerIndex = (dealerIndex + 1) % players.length;
    smallBlindIndex = (dealerIndex + 1) % players.length;
    bigBlindIndex = (dealerIndex + 2) % players.length;

    postBlinds();

    for (var player in players) {
      player.cards = deck.drawMultiple(2);
    }

    currentPlayerIndex = (bigBlindIndex + 1) % players.length;
    moveToNextActivePlayerIfNeeded();
  }

  void postBlinds() {
    if (!blindsPosted) {
      // Small blind
      double smallBlind = min(smallBlindAmount, players[smallBlindIndex].chips);
      players[smallBlindIndex].chips -= smallBlind;
      players[smallBlindIndex].currentBet = smallBlind;
      players[smallBlindIndex].totalBetThisRound = smallBlind;
      players[smallBlindIndex].lastAction =
          'Small Blind \$${smallBlind.toStringAsFixed(0)}';
      if (players[smallBlindIndex].chips <= 0) {
        players[smallBlindIndex].isAllIn = true;
      }

      // Big blind
      double bigBlind = min(bigBlindAmount, players[bigBlindIndex].chips);
      players[bigBlindIndex].chips -= bigBlind;
      players[bigBlindIndex].currentBet = bigBlind;
      players[bigBlindIndex].totalBetThisRound = bigBlind;
      players[bigBlindIndex].lastAction =
          'Big Blind \$${bigBlind.toStringAsFixed(0)}';
      if (players[bigBlindIndex].chips <= 0) {
        players[bigBlindIndex].isAllIn = true;
      }

      pot = smallBlind + bigBlind;
      currentBet = bigBlind;
      blindsPosted = true;
    }
  }

  void nextRound() {
    // Reset the number of actions taken in this betting round
    actionsThisRound = 0;

    // Advance the game to the next round
    switch (currentRound) {
      case BettingRound.preflop:
        // Move from preflop to flop
        currentRound = BettingRound.flop;
        // Draw 3 community cards and put them on the table
        communityCards = deck.drawMultiple(3);
        break;

      case BettingRound.flop:
        // Move from flop to turn
        currentRound = BettingRound.turn;
        // Draw 1 more community card (the turn)
        communityCards.add(deck.drawCard());
        break;

      case BettingRound.turn:
        // Move from turn to river
        currentRound = BettingRound.river;
        // Draw 1 more community card (the river)
        communityCards.add(deck.drawCard());
        break;

      case BettingRound.river:
        // Move from river to showdown
        currentRound = BettingRound.showdown;
        // Determine the winner of the hand based on players' hands + community cards
        determineWinner();
        break;

      case BettingRound.showdown:
        // If already at showdown, the game is over
        isGameOver = true;
        break;
    }

    // Reset each player's state for the new betting round
    for (var player in players) {
      player.resetRound();
    }

    // Reset the current bet to 0 for the new round
    currentBet = 0;

    // Set the next player to act starting from the small blind
    currentPlayerIndex = smallBlindIndex;
    // Skip any inactive/folded players to find the next active player
    moveToNextActivePlayer();
  }

  void moveToNextActivePlayer() {
    int startIndex = currentPlayerIndex;
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
      if (currentPlayerIndex == startIndex) {
        break;
      }
    } while (!players[currentPlayerIndex].isActive ||
        players[currentPlayerIndex].isFolded ||
        players[currentPlayerIndex].isAllIn);
  }

  void moveToNextActivePlayerIfNeeded() {
    if (!players[currentPlayerIndex].isActive ||
        players[currentPlayerIndex].isFolded ||
        players[currentPlayerIndex].isAllIn) {
      moveToNextActivePlayer();
    }
  }

  bool makeAction(GameAction action, {double? raiseAmount}) {
    final player = players[currentPlayerIndex];

    if (player.isFolded ||
        player.isAllIn ||
        !player.isActive ||
        player.chips < 0) {
      return false;
    }

    bool actionSuccess = false;
    double actionAmount = 0;

    switch (action) {
      case GameAction.fold:
        player.fold();
        actionSuccess = true;
        break;
      case GameAction.check:
        if (player.canCheck(currentBet)) {
          player.check();
          actionSuccess = true;
        } else {
          return false;
        }
        break;
      case GameAction.call:
        double amountToCall = currentBet - player.currentBet;
        if (amountToCall <= 0) {
          if (player.canCheck(currentBet)) {
            player.check();
            actionSuccess = true;
          }
        } else {
          if (player.chips >= amountToCall) {
            actionAmount = amountToCall;
            player.chips -= actionAmount;
            player.currentBet += actionAmount;
            player.totalBetThisRound += actionAmount;
            pot += actionAmount;
            player.lastAction = 'Call \$${actionAmount.toStringAsFixed(0)}';
            actionSuccess = true;
          } else {
            actionAmount = player.chips;
            player.currentBet += actionAmount;
            player.totalBetThisRound += actionAmount;
            pot += actionAmount;
            player.chips = 0;
            player.isAllIn = true;
            player.lastAction =
                'All-In Call \$${actionAmount.toStringAsFixed(0)}';
            actionSuccess = true;
          }
        }
        break;
      case GameAction.raise:
        if (raiseAmount != null) {
          double minRaise = currentBet * 2;
          if (raiseAmount < minRaise) {
            raiseAmount = minRaise;
          }

          if (raiseAmount > currentBet &&
              player.canRaise(raiseAmount, currentBet)) {
            double amountToRaise = raiseAmount - player.currentBet;

            if (player.chips >= amountToRaise) {
              currentBet = raiseAmount;
              actionAmount = amountToRaise;
              player.chips -= actionAmount;
              player.currentBet = raiseAmount;
              player.totalBetThisRound += actionAmount;
              pot += actionAmount;
              player.lastAction =
                  'Raise to \$${raiseAmount.toStringAsFixed(0)}';
              actionSuccess = true;
            } else {
              actionAmount = player.chips;
              player.currentBet += actionAmount;
              player.totalBetThisRound += actionAmount;
              pot += actionAmount;
              player.chips = 0;
              player.isAllIn = true;
              currentBet = max(currentBet, player.currentBet);
              player.lastAction =
                  'All-In Raise \$${actionAmount.toStringAsFixed(0)}';
              actionSuccess = true;
            }
          }
        }
        break;
      case GameAction.allIn:
        actionAmount = player.chips;
        if (actionAmount > 0) {
          player.currentBet += actionAmount;
          player.totalBetThisRound += actionAmount;
          pot += actionAmount;

          if (player.currentBet > currentBet) {
            currentBet = player.currentBet;
          }

          player.chips = 0;
          player.isAllIn = true;
          player.lastAction = 'All-In \$${actionAmount.toStringAsFixed(0)}';
          actionSuccess = true;
        }
        break;
    }

    if (actionSuccess) {
      actionsThisRound++;
      moveToNextActivePlayer();

      if (areAllActivePlayersAllIn) {
        dealRemainingCardsForAllIn();
      } else if (isBettingRoundComplete()) {
        nextRound();
      }
    }

    return actionSuccess;
  }

  void dealRemainingCardsForAllIn() {
    while (currentRound != BettingRound.showdown) {
      switch (currentRound) {
        case BettingRound.preflop:
          if (communityCards.isEmpty) {
            communityCards = deck.drawMultiple(3);
          }
          currentRound = BettingRound.flop;
          break;
        case BettingRound.flop:
          if (communityCards.length < 4) {
            communityCards.add(deck.drawCard());
          }
          currentRound = BettingRound.turn;
          break;
        case BettingRound.turn:
          if (communityCards.length < 5) {
            communityCards.add(deck.drawCard());
          }
          currentRound = BettingRound.river;
          break;
        case BettingRound.river:
          currentRound = BettingRound.showdown;
          break;
        case BettingRound.showdown:
          break;
      }
    }

    determineWinner();
  }

  bool isBettingRoundComplete() {
    List<Player> activeNonAllInPlayers = players
        .where((p) => !p.isFolded && !p.isAllIn)
        .toList();

    if (activeNonAllInPlayers.isEmpty) {
      return true;
    }

    bool allBetsMatched = true;
    for (var player in activeNonAllInPlayers) {
      if (player.currentBet < currentBet) {
        allBetsMatched = false;
        break;
      }
    }

    return allBetsMatched && actionsThisRound >= activeNonAllInPlayers.length;
  }

  bool get areAllActivePlayersAllIn {
    List<Player> activePlayers = players.where((p) => !p.isFolded).toList();
    if (activePlayers.isEmpty) return false;
    return activePlayers.every((p) => p.isAllIn);
  }

  void calculateSidePots() {
    sidePots.clear();
    sidePotPlayers.clear();

    List<Player> playersInPot = players.where((p) => !p.isFolded).toList();

    if (playersInPot.length <= 1) return;

    playersInPot.sort(
      (a, b) => a.totalBetThisRound.compareTo(b.totalBetThisRound),
    );

    double previousLevel = 0;
    for (int i = 0; i < playersInPot.length; i++) {
      double level = playersInPot[i].totalBetThisRound;
      double amountAtLevel =
          (level - previousLevel) * (playersInPot.length - i);

      if (amountAtLevel > 0) {
        sidePots.add(amountAtLevel);
        sidePotPlayers.add(playersInPot.sublist(i));
      }

      previousLevel = level;
    }
  }

  void determineWinner() {
    List<Player> activePlayers = players.where((p) => !p.isFolded).toList();

    if (activePlayers.isEmpty) {
      winners = [];
      return;
    }

    if (activePlayers.length == 1) {
      winners = [activePlayers.first];
      activePlayers.first.winPot(pot);
    } else {
      calculateSidePots();

      if (sidePots.isEmpty) {
        List<Map<String, dynamic>> playerHands = [];

        for (var player in activePlayers) {
          final hand = player.getBestHand(communityCards);
          playerHands.add({'player': player, 'hand': hand});
        }

        playerHands.sort((a, b) {
          final handA = a['hand'] as PokerHand;
          final handB = b['hand'] as PokerHand;

          if (handA.handValue != handB.handValue) {
            return handB.handValue.compareTo(handA.handValue);
          }

          for (
            int i = 0;
            i < min(handA.kickers.length, handB.kickers.length);
            i++
          ) {
            if (handA.kickers[i] != handB.kickers[i]) {
              return handB.kickers[i].compareTo(handA.kickers[i]);
            }
          }

          return 0;
        });

        final bestHand = playerHands.first['hand'] as PokerHand;
        winners = playerHands
            .where((ph) {
              final hand = ph['hand'] as PokerHand;
              if (hand.handValue != bestHand.handValue) return false;

              for (
                int i = 0;
                i < min(hand.kickers.length, bestHand.kickers.length);
                i++
              ) {
                if (hand.kickers[i] != bestHand.kickers[i]) return false;
              }
              return true;
            })
            .map((ph) => ph['player'] as Player)
            .toList();

        if (winners.isNotEmpty) {
          double amountPerWinner = pot / winners.length;
          for (var winner in winners) {
            winner.winPot(amountPerWinner);
          }
        }
      } else {
        for (int i = 0; i < sidePots.length; i++) {
          List<Player> eligiblePlayers = sidePotPlayers[i];
          List<Player> playersInPot = eligiblePlayers
              .where((p) => !p.isFolded)
              .toList();

          if (playersInPot.length == 1) {
            playersInPot.first.winPot(sidePots[i]);
          } else {
            List<Map<String, dynamic>> playerHands = [];

            for (var player in playersInPot) {
              final hand = player.getBestHand(communityCards);
              playerHands.add({'player': player, 'hand': hand});
            }

            playerHands.sort((a, b) {
              final handA = a['hand'] as PokerHand;
              final handB = b['hand'] as PokerHand;

              if (handA.handValue != handB.handValue) {
                return handB.handValue.compareTo(handA.handValue);
              }

              for (
                int j = 0;
                j < min(handA.kickers.length, handB.kickers.length);
                j++
              ) {
                if (handA.kickers[j] != handB.kickers[j]) {
                  return handB.kickers[j].compareTo(handA.kickers[j]);
                }
              }

              return 0;
            });

            final bestHand = playerHands.first['hand'] as PokerHand;
            List<Player> potWinners = playerHands
                .where((ph) {
                  final hand = ph['hand'] as PokerHand;
                  if (hand.handValue != bestHand.handValue) return false;

                  for (
                    int j = 0;
                    j < min(hand.kickers.length, bestHand.kickers.length);
                    j++
                  ) {
                    if (hand.kickers[j] != bestHand.kickers[j]) return false;
                  }
                  return true;
                })
                .map((ph) => ph['player'] as Player)
                .toList();

            if (potWinners.isNotEmpty) {
              double amountPerWinner = sidePots[i] / potWinners.length;
              for (var winner in potWinners) {
                winner.winPot(amountPerWinner);
              }
            }
          }
        }
      }
    }

    isGameOver = true;
  }

  void makeAIAction() {
    final player = players[currentPlayerIndex];
    if (!player.isAI || player.isFolded || player.isAllIn) {
      return;
    }

    final random = Random();
    double decision = random.nextDouble();

    if (currentBet == 0) {
      if (decision < 0.4) {
        makeAction(GameAction.check);
      } else if (decision < 0.9) {
        double raiseTo =
            currentBet + (random.nextDouble() * 50 + 20).roundToDouble();
        makeAction(GameAction.raise, raiseAmount: raiseTo);
      } else {
        makeAction(GameAction.fold);
      }
    } else {
      double callAmount = currentBet - player.currentBet;
      double potOdds = callAmount / (pot + callAmount);

      if (decision < potOdds * 0.3) {
        makeAction(GameAction.fold);
      } else if (decision < 0.6) {
        makeAction(GameAction.call);
      } else if (decision < 0.9 && player.chips > currentBet * 2) {
        double raiseTo = currentBet * (1.5 + random.nextDouble());
        makeAction(GameAction.raise, raiseAmount: raiseTo);
      } else {
        if (player.chips <= callAmount * 3) {
          makeAction(GameAction.allIn);
        } else {
          makeAction(GameAction.call);
        }
      }
    }
  }
}
