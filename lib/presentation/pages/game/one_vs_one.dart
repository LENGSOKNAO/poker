import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/game/poker_game.dart';
import 'package:game_poker/data/model/player.dart';
import 'package:game_poker/data/services/data_manager.dart';
import 'package:game_poker/widget/cards/realistPlayCard.dart';
import 'package:game_poker/widget/panenls/minii_action_panel.dart';

class GameOneVsOne extends StatefulWidget {
  const GameOneVsOne({super.key});

  @override
  State<GameOneVsOne> createState() => _GameOneVsOneState();
}

class _GameOneVsOneState extends State<GameOneVsOne> {
  final DataManager _dataManager = DataManager();
  final TextEditingController _betController = TextEditingController();

  PokerGame? _game;
  Player? _humanPlayer;
  bool _gameOn = false;

  @override
  void initState() {
    super.initState();
    _betController.text = '1000';
  }

  @override
  void dispose() {
    _betController.dispose();
    super.dispose();
  }

  void _play() async {
    final bet = double.tryParse(_betController.text);
    final user = _dataManager.currentUser;

    // Validation checks
    if (user == null) {
      _showError('User not found!');
      return;
    }

    if (bet == null || bet <= 0) {
      _showError('Please enter a valid bet amount!');
      return;
    }

    if (bet > user.balance) {
      _showError(
        'Insufficient balance!\nYour balance: \$${user.balance.toStringAsFixed(0)}\nBet amount: \$${bet.toStringAsFixed(0)}',
      );
      return;
    }

    user.balance -= bet;
    await _dataManager.updateUser(user);

    _game = PokerGame([user.name, "Opponent"], bet, numPlayer: 2);
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    setState(() => _gameOn = true);
  }

  void _makeAction(GameAction action, {double? raiseAmount}) {
    if (_game == null || _game!.isGameover) return;

    final player = _game!.players[_game!.currentPlayerIndex];

    if (player.isAI) {
      _showError("Not Your True!");
      return;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Error',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade900.withOpacity(0.7),
                    Colors.blue.shade900.withOpacity(0.8),
                    Colors.indigo.shade900.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          _gameOn ? _table() : _lobby(),
        ],
      ),
    );
  }

  Widget _lobby() {
    final user = _dataManager.currentUser;

    return SafeArea(
      child: Column(
        children: [
          // Top
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.black87,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '\$${user?.balance.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.casino,
                      size: 50,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Title
                  const Text(
                    'TEXAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                    ),
                  ),
                  const Text(
                    'HOLD\'EM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'HEAD TO HEAD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Bet
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ENTER YOUR BET',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '\$',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _betController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.w900,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.white24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [100, 500, 1000, 5000, 10000].map((val) {
                      return GestureDetector(
                        onTap: () {
                          _betController.text = val.toString();
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            '\$${val}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  // Play
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _play,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 10,
                      ),
                      child: const Text(
                        'PLAY NOW',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table() {
    if (_game == null) return const SizedBox();

    final opp = _game!.players[1];
    final call = _humanPlayer != null
        ? _game!.currentBet - _humanPlayer!.currentBet
        : 0.0;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => setState(() => _gameOn = false),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'TEXAS HOLD\'EM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                // Opponent
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: _playerCard(
                    name: 'OPPONENT',
                    chips: opp.chips,
                    action: opp.lastAction,
                    cards: opp.cards,
                    isOpponent: true,
                  ),
                ),

                // Middle
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pot
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'POT',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${_game!.pot.toInt()}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Community
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'COMMUNITY',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_game!.communityCards.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: _game!.communityCards
                                    .map(
                                      (c) => Realistplaycard(
                                        card: c,
                                        width: 48,
                                        height: 70,
                                      ),
                                    )
                                    .toList(),
                              )
                            else
                              Container(
                                width: 90,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // You
                Positioned(
                  bottom: 90,
                  left: 16,
                  right: 16,
                  child: _playerCard(
                    name: 'YOU',
                    chips: _humanPlayer?.chips ?? 0,
                    action: _humanPlayer?.lastAction ?? '',
                    cards: _humanPlayer?.cards ?? [],
                    isOpponent: false,
                    callAmount: call,
                  ),
                ),
              ],
            ),
          ),

          if (!_game!.isGameover &&
              !_game!.players[_game!.currentPlayerIndex].isAI &&
              !_game!.players[_game!.currentPlayerIndex].isFolded &&
              !_game!.players[_game!.currentPlayerIndex].isAllIn)
            MiniiActionPanel(
              onActionSelected: (action, raiseAmount) {
                if (action == GameAction.raise && raiseAmount != null) {
                  _makeAction(action, raiseAmount: raiseAmount);
                } else {
                  _makeAction(action);
                }
              },
              crrentBet: _game!.currentBet,
              playerCurrentBet: _humanPlayer!.currentBet,
              isCheck: _humanPlayer!.isCheck(_game!.currentBet),
              isCall: _humanPlayer!.isCall(_game!.currentBet),
              isRaise: _humanPlayer!.chips > 0,
              onAutonFold: () => _makeAction(GameAction.fold),
            ),
        ],
      ),
    );
  }

  Widget _playerCard({
    required String name,
    required double chips,
    required String action,
    required List cards,
    required bool isOpponent,
    double callAmount = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${chips.toInt()}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (callAmount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${callAmount.toInt()}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (action.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                action,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cards.isNotEmpty)
                Realistplaycard(
                  card: cards[0],
                  isHidden:
                      isOpponent &&
                      !(_game?.players[1].isAllIn ?? false) &&
                      !(_game?.players[1].isFolded ?? false) &&
                      !(_game?.isGameover ?? false) &&
                      !(_game?.areAllActivePlayerAllIn ?? false),
                  width: 48,
                  height: 70,
                ),
              if (cards.length > 1) const SizedBox(width: 8),
              if (cards.length > 1)
                Realistplaycard(
                  card: cards[1],
                  isHidden:
                      isOpponent &&
                      !(_game?.currentRound == BettingRound.showdown) &&
                      !(_game?.players[1].isAllIn ?? false) &&
                      !(_game?.players[1].isFolded ?? false) &&
                      !(_game?.isGameover ?? false) &&
                      !(_game?.areAllActivePlayerAllIn ?? false),
                  width: 48,
                  height: 70,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
