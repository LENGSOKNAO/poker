import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/game/poker_game.dart';
import 'package:game_poker/data/model/card_model.dart';
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

    // Only deduct bet on first game
    user.balance -= bet;
    await _dataManager.updateUser(user);

    _game = PokerGame([user.name, "Opponent"], bet, numPlayers: 2);
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    setState(() => _gameOn = true);
  }

  void _makeAction(GameAction action, {double? raiseAmount}) {
    if (_game == null || _game!.isGameOver) return;

    final player = _game!.players[_game!.currentPlayerIndex];

    if (player.isAI) {
      _showError("Not Your Turn!");
      return;
    }

    setState(() {
      _game!.makeAction(action, raiseAmount: raiseAmount);
    });

    if (!_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex].isAI &&
        !_game!.players[_game!.currentPlayerIndex].isFolded) {
      _handleAIAction();
    }
  }

  void _handleAIAction() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted || _game == null || _game!.isGameOver) return;

    setState(() {
      _game!.makeAIAction();
    });

    if (!_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex].isAI &&
        !_game!.players[_game!.currentPlayerIndex].isFolded) {
      _handleAIAction();
    }
  }

  void _updateBalanceFromGame() {
    final user = _dataManager.currentUser;
    if (user != null && _humanPlayer != null) {
      // Update user balance to match player's chips
      user.balance = _humanPlayer!.chips;
      _dataManager.updateUser(user);
      print('Balance updated: ${user.balance}');
    }
  }

  void _showWinnerDialog(List<Player> winners) {
    // Update balance with winnings
    _updateBalanceFromGame();

    // Store the pot amount before showing dialog
    final potAmount = _game!.pot;
    final user = _dataManager.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'GAME OVER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 16),
            Text(
              'Winner: ${winners.isEmpty ? 'No one' : winners.first.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Prize: \$${potAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR NEW BALANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${user?.balance.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Click NEW ROUND button to play again!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startNewRound() {
    if (!mounted) return;

    final user = _dataManager.currentUser;
    if (user == null) {
      setState(() => _gameOn = false);
      return;
    }

    final currentBet = double.tryParse(_betController.text) ?? 1000;

    // Check if user has enough balance (allow equal)
    if (currentBet > user.balance) {
      _showInsufficientBalanceDialog(user.balance);
      return;
    }

    // Store current chips before creating new game
    final currentHumanChips = _humanPlayer?.chips ?? user.balance;
    final currentOpponentChips = _game?.players[1].chips ?? currentBet;

    // Create new game with fresh deck and cards
    _game = PokerGame([user.name, "Opponent"], currentBet, numPlayers: 2);
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    // Restore the actual chip counts from previous game (including winnings)
    _humanPlayer!.chips = currentHumanChips;
    _game!.players[1].chips = currentOpponentChips;

    // Update user balance in data manager
    user.balance = _humanPlayer!.chips;
    _dataManager.updateUser(user);

    setState(() {
      // Keep _gameOn as true (stay in game)
    });

    print('=== NEW ROUND STARTED ===');
    print('Human player balance: ${_humanPlayer?.chips}');
    print('Opponent balance: ${_game!.players[1].chips}');
    print('Human player cards: ${_humanPlayer?.cards.length}');
    print('Opponent cards: ${_game!.players[1].cards.length}');
    print('Game round: ${_game!.currentRound}');
    print('=======================');
  }

  void _showInsufficientBalanceDialog(double currentBalance) {
    final TextEditingController newBetController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Insufficient Balance',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Balance:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '\$${currentBalance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You don\'t have enough chips to play another round with the current bet amount.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter new bet amount:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newBetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _gameOn = false;
                      _game = null;
                      _humanPlayer = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'LEAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newBet = double.tryParse(newBetController.text);
                    if (newBet == null || newBet <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid amount'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (newBet > currentBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Amount cannot exceed your balance of \$${currentBalance.toStringAsFixed(0)}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Update bet controller with new amount
                    _betController.text = newBet.toString();
                    Navigator.pop(context);

                    // Start new round with new bet amount
                    _startNewRoundWithNewBet(newBet);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'UPDATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startNewRoundWithNewBet(double newBet) {
    if (!mounted) return;

    final user = _dataManager.currentUser;
    if (user == null) {
      setState(() => _gameOn = false);
      return;
    }

    // Store current chips before creating new game
    final currentHumanChips = _humanPlayer?.chips ?? user.balance;
    final currentOpponentChips = _game?.players[1].chips ?? newBet;

    // Create new game with fresh deck and cards using new bet amount
    _game = PokerGame([user.name, "Opponent"], newBet, numPlayers: 2);
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    // Restore the actual chip counts from previous game (including winnings)
    _humanPlayer!.chips = currentHumanChips;
    _game!.players[1].chips = currentOpponentChips;

    // Update user balance in data manager
    user.balance = _humanPlayer!.chips;
    _dataManager.updateUser(user);

    setState(() {
      // Keep _gameOn as true (stay in game)
    });

    print('=== NEW ROUND STARTED WITH NEW BET: $newBet ===');
    print('Human player balance: ${_humanPlayer?.chips}');
    print('Opponent balance: ${_game!.players[1].chips}');
    print('Game round: ${_game!.currentRound}');
    print('=======================');
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

    // Check if player has any chips
    final bool hasChips =
        _humanPlayer?.chips != null && _humanPlayer!.chips > 0;

    // Check if player can make any legal action
    final bool canMakeAction =
        hasChips &&
        (_humanPlayer!.canCheck(_game!.currentBet) ||
            _humanPlayer!.canCall(_game!.currentBet) ||
            (_humanPlayer!.chips > 0 &&
                _humanPlayer!.canRaise(
                  _game!.currentBet + 20.0,
                  _game!.currentBet,
                )));

    // Only show action panel if it's human turn, game not over, player not folded/all-in, AND player can actually do something
    final bool showActionPanel =
        !_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex] == _humanPlayer &&
        !_humanPlayer!.isFolded &&
        !_humanPlayer!.isAllIn &&
        canMakeAction;

    // Get winner/no chips info for display
    String infoMessage = '';
    Color infoColor = Colors.white;
    IconData infoIcon = Icons.info;

    if (_game!.isGameOver) {
      if (_game!.winners.isNotEmpty) {
        final winner = _game!.winners.first;
        infoMessage = winner == _humanPlayer
            ? '🎉 YOU WIN! 🎉'
            : '😢 OPPONENT WINS';
        infoColor = winner == _humanPlayer ? Colors.amber : Colors.grey;
        infoIcon = winner == _humanPlayer
            ? Icons.emoji_events
            : Icons.sentiment_dissatisfied;
      } else {
        infoMessage = 'GAME OVER';
        infoColor = Colors.grey;
      }
    } else if (!hasChips) {
      infoMessage = '⚠️ NO CHIPS LEFT ⚠️';
      infoColor = Colors.red;
      infoIcon = Icons.warning_amber_rounded;
    } else if (!canMakeAction && hasChips) {
      infoMessage = '⚠️ CANNOT MAKE ACTION ⚠️';
      infoColor = Colors.orange;
      infoIcon = Icons.warning;
    }

    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          // Compact Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36.0,
                      minHeight: 36.0,
                    ),
                    onPressed: () => setState(() {
                      _gameOn = false;
                      _game = null;
                      _humanPlayer = null;
                    }),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                ),

                // Game title (smaller on mobile)
                Expanded(
                  child: Center(
                    child: Text(
                      'TEXAS HOLD\'EM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 360 ? 12.0 : 14.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // New Round button when game is over OR player has no chips
                if (_game!.isGameOver || !hasChips || !canMakeAction)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36.0,
                        minHeight: 36.0,
                      ),
                      onPressed: _startNewRound,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      tooltip: 'New Round',
                    ),
                  )
                else
                  const SizedBox(width: 36.0), // Match back button width
              ],
            ),
          ),

          // Info Message Banner (game over or no chips)
          if (infoMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    infoColor.withOpacity(0.7),
                    infoColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: infoColor.withOpacity(0.3),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(infoIcon, color: Colors.white, size: 18.0),
                  const SizedBox(width: 6.0),
                  Text(
                    infoMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (_game!.isGameOver) ...[
                    const SizedBox(width: 6.0),
                    Text(
                      '\$${_game!.pot.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Expanded(
            child: Stack(
              children: [
                // Opponent Card (positioned at top)
                Positioned(
                  top: 0.0,
                  left: 16.0,
                  right: 16.0,
                  child: _playerCard(
                    name: 'OPPONENT',
                    chips: opp.chips,
                    action: opp.lastAction,
                    cards: opp.cards,
                    isOpponent: true,
                  ),
                ),

                // Center content - Pot and Community Cards
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pot - smaller on mobile
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
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
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              '\$${_game!.pot.toInt()}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Community Cards - compact layout
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'COMMUNITY',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (_game!.communityCards.isNotEmpty)
                              Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children: _game!.communityCards
                                    .map(
                                      (c) => Realistplaycard(
                                        card: c,
                                        width: screenWidth < 360 ? 40.0 : 44.0,
                                        height: screenWidth < 360 ? 58.0 : 64.0,
                                      ),
                                    )
                                    .toList(),
                              )
                            else
                              Container(
                                width: 80.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No cards',
                                    style: TextStyle(
                                      color: Colors.white30,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ),
                              ),

                            // New Round button in center (always show when game over or no chips)
                            if (_game!.isGameOver ||
                                !hasChips ||
                                !canMakeAction)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton.icon(
                                  onPressed: _startNewRound,
                                  icon: const Icon(Icons.refresh, size: 16.0),
                                  label: const Text(
                                    'START NEW ROUND',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                      vertical: 12.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // You Card (positioned at bottom)
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: _playerCard(
                    name: 'YOU',
                    chips: _humanPlayer?.chips ?? 0.0,
                    action: _humanPlayer?.lastAction ?? '',
                    cards: _humanPlayer?.cards ?? [],
                    isOpponent: false,
                    callAmount: call,
                  ),
                ),
              ],
            ),
          ),

          // Action Panel - only when player can actually make an action
          if (showActionPanel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: MiniiActionPanel(
                key: ValueKey(
                  'action_panel_${_game!.currentPlayerIndex}_${_game!.currentRound}',
                ),
                onActionSelected: (action, raiseAmount) {
                  _makeAction(action, raiseAmount: raiseAmount);
                },
                currentBet: _game!.currentBet,
                playerCurrentBet: _humanPlayer!.currentBet,
                isCheckAvailable: _humanPlayer!.canCheck(_game!.currentBet),
                isCallAvailable: _humanPlayer!.canCall(_game!.currentBet),
                isRaiseAvailable:
                    _humanPlayer!.chips > 0 &&
                    _humanPlayer!.canRaise(
                      _game!.currentBet + 20.0,
                      _game!.currentBet,
                    ),
                autoFoldDuration: const Duration(seconds: 15),
                onAutoFold: () {
                  _makeAction(GameAction.fold);
                },
                playerChips: _humanPlayer!.chips,
              ),
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
    double callAmount = 0.0,
  }) {
    // Safely cast cards to List<CardModel>
    final List<CardModel> cardModels = [];
    try {
      for (var card in cards) {
        if (card is CardModel) {
          cardModels.add(card);
        }
      }
    } catch (e) {
      print('Error casting cards: $e');
    }

    // Adjust card size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 360 ? 40.0 : 44.0;
    final cardHeight = screenWidth < 360 ? 58.0 : 64.0;

    return Container(
      padding: EdgeInsets.all(screenWidth < 360 ? 10.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 360 ? 12.0 : 13.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  // Chips display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      '\$${chips.toInt()}',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: screenWidth < 360 ? 11.0 : 12.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (callAmount > 0) ...[
                    const SizedBox(width: 4.0),
                    // Call amount display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        '\$${callAmount.toInt()}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: screenWidth < 360 ? 10.0 : 11.0,
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
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                action,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10.0,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cardModels.isNotEmpty)
                Realistplaycard(
                  card: cardModels[0],
                  isHidden:
                      isOpponent &&
                      !(_game?.players[1].isAllIn ?? false) &&
                      !(_game?.players[1].isFolded ?? false) &&
                      !(_game?.isGameOver ?? false) &&
                      !(_game?.areAllActivePlayersAllIn ?? false),
                  width: cardWidth,
                  height: cardHeight,
                )
              else
                _buildPlaceholderCard(cardWidth, cardHeight),

              if (cardModels.length > 1) const SizedBox(width: 4.0),

              if (cardModels.length > 1)
                Realistplaycard(
                  card: cardModels[1],
                  isHidden:
                      isOpponent &&
                      !(_game?.currentRound == BettingRound.showdown) &&
                      !(_game?.players[1].isAllIn ?? false) &&
                      !(_game?.players[1].isFolded ?? false) &&
                      !(_game?.isGameOver ?? false) &&
                      !(_game?.areAllActivePlayersAllIn ?? false),
                  width: cardWidth,
                  height: cardHeight,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Center(
        child: Text('?', style: TextStyle(color: Colors.white, fontSize: 16.0)),
      ),
    );
  }
}
