import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/data/game/poker_game.dart';
import 'package:game_poker/data/model/player.dart';
import 'package:game_poker/data/model/poker_hand.dart';
import 'package:game_poker/widget/cards/realistPlayCard.dart';
import 'package:game_poker/widget/panenls/minii_action_panel.dart';
import '../../../data/services/data_manager.dart';

class TexasHoldemPage extends StatefulWidget {
  const TexasHoldemPage({super.key});

  @override
  State<TexasHoldemPage> createState() => _TexasHoldemPageState();
}

// Custom painter for loading border
class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  ProgressBorderPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
    this.borderRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress > 1) return;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Background border (faint)
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, backgroundPaint);

    // Progress border
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.addRRect(rrect);

    final pathMetrics = path.computeMetrics().first;
    final progressLength = pathMetrics.length * progress;
    final extractPath = pathMetrics.extractPath(0, progressLength);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(ProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _TexasHoldemPageState extends State<TexasHoldemPage> {
  final DataManager _dataManager = DataManager();
  final TextEditingController _buyInController = TextEditingController(
    text: '100',
  );

  PokerGame? _game;
  bool _isGameActive = false;
  Player? _humanPlayer;
  String _gameMessage = 'Welcome to Texas Hold\'em!';

  int? _selectedPlayerIndex;
  bool _showPlayerHandDialog = false;
  Player? _selectedPlayer;
  PokerHand? _selectedPlayerHand;

  // Timer for auto-fold (ONLY for human player)
  Timer? _autoFoldTimer;
  int _secondsRemaining = 0;
  final int _autoFoldDuration = 15; // 15 seconds

  // Flag to prevent multiple AI actions
  bool _isProcessingAIAction = false;

  // Winner tracking
  String _winnerMessage = '';
  double _winningAmount = 0;

  Color _getProgressColor() {
    if (_secondsRemaining <= 3) {
      return Colors.red.shade400;
    } else if (_secondsRemaining <= 6) {
      return Colors.orange.shade400;
    } else {
      return Colors.green.shade400;
    }
  }

  @override
  void initState() {
    super.initState();
    _buyInController.text = '100';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _autoFoldTimer?.cancel();
    _buyInController.dispose();
    super.dispose();
  }

  void _startAutoFoldTimer() {
    // Only start timer for human player
    if (_game == null || _game!.isGameOver) return;

    final currentPlayer = _game!.players[_game!.currentPlayerIndex];

    // Only start timer if it's human player's turn
    if (currentPlayer == _humanPlayer &&
        !currentPlayer.isFolded &&
        !currentPlayer.isAllIn) {
      _autoFoldTimer?.cancel();
      setState(() {
        _secondsRemaining = _autoFoldDuration;
      });

      _autoFoldTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _game == null || _game!.isGameOver) {
          timer.cancel();
          return;
        }

        // Check if it's still human player's turn
        final currentPlayerNow = _game!.players[_game!.currentPlayerIndex];
        if (currentPlayerNow != _humanPlayer ||
            currentPlayerNow.isFolded ||
            currentPlayerNow.isAllIn) {
          timer.cancel();
          return;
        }

        setState(() {
          _secondsRemaining--;
        });

        if (_secondsRemaining <= 0) {
          timer.cancel();
          _autoFold();
        }
      });
    } else {
      // For AI players, cancel any existing timer and reset seconds to 0
      _autoFoldTimer?.cancel();
      setState(() {
        _secondsRemaining = 0;
      });
    }
  }

  void _autoFold() {
    if (_game == null || _game!.isGameOver) return;

    final player = _game!.players[_game!.currentPlayerIndex];
    if (player == _humanPlayer && !player.isFolded && !player.isAllIn) {
      _makeAction(GameAction.fold);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time\'s up! Auto-folded'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetTimer() {
    if (_game != null &&
        _game!.players[_game!.currentPlayerIndex] == _humanPlayer &&
        !_humanPlayer!.isFolded &&
        !_humanPlayer!.isAllIn) {
      setState(() {
        _secondsRemaining = _autoFoldDuration;
      });
    }
  }

  Future<void> _startGame() async {
    final buyIn = double.tryParse(_buyInController.text);
    final user = _dataManager.currentUser;

    if (buyIn == null || buyIn <= 0) {
      _showError('Please enter a valid buy-in amount');
      return;
    }

    if (user == null) {
      _showError('User not found!');
      return;
    }

    if (user.balance < buyIn) {
      _showError(
        'Insufficient funds! You need \$${buyIn.toStringAsFixed(0)} to play.',
      );
      return;
    }

    user.balance -= buyIn;
    await _dataManager.updateUser(user);

    final playerNames = [
      user.name,
      'AI 1',
      'AI 2',
      'AI 3',
      'AI 4',
      'AI 5',
      'AI 6',
      'AI 7',
      'AI 8',
    ];

    setState(() {
      _game = PokerGame(playerNames, buyIn, numPlayers: 9);
      _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);
      _isGameActive = true;
      _gameMessage = 'Game started! Your turn.';
      _secondsRemaining = _autoFoldDuration;
      _isProcessingAIAction = false;
      _winnerMessage = '';
      _winningAmount = 0;
    });

    _startAutoFoldTimer();
    _processGame();
  }

  void _selectPlayer(int index) {
    if (_game == null || index >= _game!.players.length) return;

    final player = _game!.players[index];

    // ONLY allow viewing cards if:
    // 1. Game is over (show all cards)
    // 2. Player has folded (show their cards)
    // 3. It's the human player's own cards (always show)
    // 4. All players are all-in (show all)

    final bool canViewCards =
        _game!.isGameOver || // Game finished
        player.isFolded || // Player folded
        player == _humanPlayer || // Human player's own cards
        _game!.areAllActivePlayersAllIn || // All players all-in
        _humanPlayer?.chips == 0; // Human has no chips

    if (!canViewCards) {
      // Show appropriate message based on situation
      String message = 'Cards are hidden until showdown!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _selectedPlayerIndex = index;
      _selectedPlayer = player;
      _selectedPlayerHand = player.getBestHand(_game!.communityCards);
      _showPlayerHandDialog = true;
    });
  }

  void _processGame() {
    if (_game == null || _game!.isGameOver) {
      _autoFoldTimer?.cancel();
      return;
    }

    // Check if human player has no chips
    if (_humanPlayer!.chips <= 0) {
      _handleNoChipsSituation();
      return;
    }

    // Check if all players are all-in
    if (_game!.areAllActivePlayersAllIn) {
      _gameMessage = 'All players are all-in! Dealing remaining cards...';
      setState(() {});

      // Automatically complete the rounds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted || _game == null) return;

        while (!_game!.isGameOver &&
            _game!.currentRound != BettingRound.showdown) {
          _game!.nextRound();
        }

        if (_game!.isGameOver) {
          _endGame();
        } else {
          setState(() {});
        }
      });
      return;
    }

    final currentPlayer = _game!.players[_game!.currentPlayerIndex];

    // Start timer only for human player
    _startAutoFoldTimer();

    if (currentPlayer.isAI && !_isProcessingAIAction) {
      _isProcessingAIAction = true;

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _game == null || _game!.isGameOver) {
          _isProcessingAIAction = false;
          return;
        }

        // Make AI action
        _game!.makeAIAction();

        setState(() {});

        // Check if game is over after AI action
        if (_game!.isGameOver) {
          _endGame();
          _isProcessingAIAction = false;
          return;
        }

        // Check if betting round is complete
        if (_game!.isBettingRoundComplete()) {
          _game!.nextRound();
          setState(() {});

          if (_game!.isGameOver) {
            _endGame();
            _isProcessingAIAction = false;
            return;
          }
        }

        _isProcessingAIAction = false;

        // Continue game processing
        if (!_game!.isGameOver) {
          _processGame();
        }
      });
    } else if (!currentPlayer.isAI) {
      // Human player's turn with chips
      setState(() {
        _gameMessage = 'Your turn. ${_getCurrentBetInfo()}';
      });
    }
  }

  void _handleNoChipsSituation() {
    _autoFoldTimer?.cancel();

    setState(() {
      _gameMessage = '⚠️ NO CHIPS LEFT - SHOWING ALL CARDS ⚠️';
    });

    // Force game to showdown
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || _game == null) return;

      // Go to showdown
      while (!_game!.isGameOver &&
          _game!.currentRound != BettingRound.showdown) {
        _game!.nextRound();
      }

      // Determine winner based on best hands
      if (_game!.isGameOver) {
        _endGame();
      } else {
        // If not over yet, force end game
        _forceEndGame();
      }
    });
  }

  void _forceEndGame() {
    if (_game == null) return;

    // Find the player with the best hand
    Player? bestPlayer;
    PokerHand? bestHand;

    for (var player in _game!.players) {
      if (!player.isFolded) {
        var hand = player.getBestHand(_game!.communityCards);
        if (bestHand == null || hand.handValue > bestHand.handValue) {
          bestHand = hand;
          bestPlayer = player;
        }
      }
    }

    if (bestPlayer != null) {
      _game!.winners = [bestPlayer];
    }

    _game!.isGameOver = true;
    _endGame();
  }

  String _getCurrentBetInfo() {
    if (_game == null) return '';
    double callAmount = _humanPlayer != null
        ? _game!.currentBet - _humanPlayer!.currentBet
        : 0;
    return 'Bet: \$${_game!.currentBet.toStringAsFixed(0)} | Call: \$${callAmount.toStringAsFixed(0)} | Pot: \$${_game!.pot.toStringAsFixed(0)}';
  }

  void _makeAction(GameAction action, {double? raiseAmount}) {
    if (_game == null || _game!.isGameOver) return;

    final player = _game!.players[_game!.currentPlayerIndex];
    if (player.isAI) {
      _showError('Not your turn!');
      return;
    }

    // Check if player has chips to make action
    if (_humanPlayer!.chips <= 0) {
      _handleNoChipsSituation();
      return;
    }

    bool success = _game!.makeAction(action, raiseAmount: raiseAmount);

    if (success) {
      setState(() {});

      if (_game!.isGameOver) {
        _autoFoldTimer?.cancel();
        _endGame();
      } else {
        _processGame();
      }
    } else {
      _showError('Invalid action!');
    }
  }

  void _endGame() {
    _autoFoldTimer?.cancel();
    _isProcessingAIAction = false;

    if (_game == null) return;

    final user = _dataManager.currentUser;

    // Calculate winnings
    if (_game!.winners.isNotEmpty) {
      _winningAmount = _game!.pot / _game!.winners.length;

      // Update player balances
      for (var winner in _game!.winners) {
        if (winner == _humanPlayer) {
          // Human player wins
          user?.balance += _winningAmount;
          user?.wins = (user?.wins ?? 0) + 1;
          user?.points = (user?.points ?? 0) + 10;

          _winnerMessage = '🎉 YOU WIN! 🎉';
        } else {
          // AI wins
          _winnerMessage = '😞 ${winner.name} Wins';
        }
      }

      // Update user in database
      if (user != null) {
        user.gamesPlayed = (user.gamesPlayed ?? 0) + 1;
        _dataManager.updateUser(user);
      }

      // Create winner message
      String winnerNames = _game!.winners.map((w) => w.name).join(', ');
      _gameMessage = '🏆 Winner: $winnerNames!';
    }

    setState(() {});
  }

  void _startNewRound() {
    _autoFoldTimer?.cancel();
    _isProcessingAIAction = false;

    if (!mounted || _game == null || _humanPlayer == null) return;

    final user = _dataManager.currentUser;
    if (user == null) return;

    // Check if player has enough chips to continue
    if (_humanPlayer!.chips <= 0) {
      _showError('You have no chips left! Please buy-in again.');
      setState(() {
        _isGameActive = false;
        _game = null;
      });
      return;
    }

    final humanChips = _humanPlayer!.chips;
    final playerNames = [
      _humanPlayer!.name,
      'AI 1',
      'AI 2',
      'AI 3',
      'AI 4',
      'AI 5',
      'AI 6',
      'AI 7',
      'AI 8',
    ];

    setState(() {
      _game = PokerGame(playerNames, humanChips, numPlayers: 9);
      _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);
      _humanPlayer!.chips = humanChips;

      // Set AI chips
      for (int i = 0; i < _game!.players.length; i++) {
        if (_game!.players[i].isAI) {
          _game!.players[i].chips = 1000;
        }
      }

      _gameMessage = 'New round started! Your turn.';
      _secondsRemaining = _autoFoldDuration;
      _winnerMessage = '';
      _winningAmount = 0;
    });

    _processGame();
  }

  void _quitToLobby() {
    _autoFoldTimer?.cancel();
    setState(() {
      _isGameActive = false;
      _game = null;
      _humanPlayer = null;
      _gameMessage = 'Welcome to Texas Hold\'em!';
      _winnerMessage = '';
    });
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
          _isGameActive && _game != null ? _buildGameTable() : _buildLobby(),
          if (_showPlayerHandDialog) _buildPlayerHandDialog(),
        ],
      ),
    );
  }

  Widget _buildLobby() {
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
                      '9 PLAYER TABLE',
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
                          'ENTER YOUR BUY-IN',
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
                                controller: _buyInController,
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
                    children: [100, 500, 1000, 5000].map((val) {
                      return GestureDetector(
                        onTap: () {
                          _buyInController.text = val.toString();
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
                      onPressed: _startGame,
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

  Widget _buildGameTable() {
    if (_game == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool hasChips =
        _humanPlayer?.chips != null && _humanPlayer!.chips > 0;

    // Simplified condition for showing action panel
    final bool isHumanTurn =
        !_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex] == _humanPlayer &&
        !_humanPlayer!.isFolded &&
        !_humanPlayer!.isAllIn;

    // Only show action panel if player has chips AND it's their turn
    final bool showActionPanel = isHumanTurn && hasChips;

    String infoMessage = _gameMessage;
    Color infoColor = Colors.white;

    if (_game!.isGameOver) {
      if (_game!.winners.contains(_humanPlayer)) {
        infoMessage = '🎉 YOU WIN! 🎉';
        infoColor = Colors.green.shade600;
      } else if (_game!.winners.isNotEmpty) {
        infoMessage = '😞 ${_game!.winners.first.name} WINS';
        infoColor = Colors.red.shade700;
      }
    } else if (!hasChips) {
      infoMessage = '⚠️ NO CHIPS LEFT - SHOWING ALL CARDS ⚠️';
      infoColor = Colors.orange.shade800;
    } else if (_game!.areAllActivePlayersAllIn) {
      infoMessage = 'ALL PLAYERS ALL IN';
      infoColor = Colors.orange.shade800;
    }

    return Column(
      children: [
        // Header
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36.0,
                    minHeight: 36.0,
                  ),
                  onPressed: _quitToLobby,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '♠️ TEXAS HOLD\'EM (9P) ♥️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth < 360 ? 11.0 : 13.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: screenWidth < 360 ? 12 : 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '\$${_game!.pot.toInt()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 360 ? 10 : 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Winner message with amount
        if (_game!.isGameOver && _winnerMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _game!.winners.contains(_humanPlayer)
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _game!.winners.contains(_humanPlayer)
                        ? Colors.green
                        : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _winnerMessage,
                      style: TextStyle(
                        color: _game!.winners.contains(_humanPlayer)
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Won: \$${_winningAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Timer display ONLY for human player with chips
        if (isHumanTurn && hasChips)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getProgressColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getProgressColor(), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: _getProgressColor(),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_secondsRemaining s',
                      style: TextStyle(
                        color: _getProgressColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '- Your turn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Info message
        if (infoMessage.isNotEmpty && !_game!.isGameOver)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: infoColor, width: 1),
                ),
                child: Text(
                  infoMessage,
                  style: TextStyle(
                    color: infoColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

        // Game area
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Center pot and community cards
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'POT: \$${_game!.pot.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'COMMUNITY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          if (_game!.communityCards.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: _game!.communityCards
                                  .map(
                                    (c) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      child: Realistplaycard(
                                        card: c,
                                        width: screenWidth < 360 ? 28.0 : 32.0,
                                        height: screenWidth < 360 ? 40.0 : 46.0,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          else
                            Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.10),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 3,
                                    sigmaY: 3,
                                  ),
                                  child: Container(
                                    color: Colors.white.withOpacity(0.03),
                                    child: const Center(
                                      child: Text(
                                        'DEALING',
                                        style: TextStyle(
                                          color: Colors.white24,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
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

              // Players
              // Top row
              Positioned(
                top: 5,
                left: screenWidth * 0.15,
                child: _buildPlayerCard(0),
              ),
              Positioned(
                top: 5,
                left: screenWidth * 0.4,
                child: _buildPlayerCard(1),
              ),
              Positioned(
                top: 5,
                right: screenWidth * 0.15,
                child: _buildPlayerCard(2),
              ),

              // Middle left
              Positioned(
                top: screenHeight * 0.2,
                left: 5,
                child: _buildPlayerCard(3),
              ),

              // Middle right
              Positioned(
                top: screenHeight * 0.2,
                right: 5,
                child: _buildPlayerCard(4),
              ),

              // Bottom row
              Positioned(
                bottom: 5,
                left: screenWidth * 0.1,
                child: _buildPlayerCard(5),
              ),
              Positioned(
                bottom: 5,
                left: screenWidth * 0.3,
                child: _buildPlayerCard(6),
              ),
              Positioned(
                bottom: 5,
                right: screenWidth * 0.3,
                child: _buildPlayerCard(7),
              ),
              Positioned(
                bottom: 5,
                right: screenWidth * 0.1,
                child: _buildPlayerCard(8),
              ),

              // Play Again and Quit buttons for game over
              if (_game!.isGameOver)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quit button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _quitToLobby,
                              borderRadius: BorderRadius.circular(25),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'QUIT',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Play Again button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _startNewRound,
                              borderRadius: BorderRadius.circular(25),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'PLAY AGAIN',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Action panel - ONLY show if player has chips
              if (showActionPanel)
                Positioned(
                  bottom: 0,
                  left: 5,
                  right: 5,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: MiniiActionPanel(
                      key: ValueKey(
                        'action_panel_${_game!.currentPlayerIndex}_${_game!.currentRound}',
                      ),
                      onActionSelected: (action, raiseAmount) {
                        if (action == GameAction.raise && raiseAmount != null) {
                          _makeAction(action, raiseAmount: raiseAmount);
                        } else {
                          _makeAction(action);
                        }
                      },
                      currentBet: _game!.currentBet,
                      playerCurrentBet: _humanPlayer!.currentBet,
                      isCheckAvailable: _humanPlayer!.canCheck(
                        _game!.currentBet,
                      ),
                      isCallAvailable: _humanPlayer!.canCall(_game!.currentBet),
                      isRaiseAvailable:
                          _humanPlayer!.chips > 0 &&
                          _humanPlayer!.canRaise(
                            _game!.currentBet + 20.0,
                            _game!.currentBet,
                          ),
                      autoFoldDuration: const Duration(seconds: 15),
                      onAutoFold: () => _makeAction(GameAction.fold),
                      playerChips: _humanPlayer!.chips,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(int index) {
    if (_game == null || index >= _game!.players.length)
      return const SizedBox();

    final player = _game!.players[index];
    final isCurrentPlayer = index == _game!.currentPlayerIndex;
    final isHuman = !player.isAI;
    final isFolded = player.isFolded;
    final isAllIn = player.isAllIn;

    // Determine if cards should be visible on the card face
    // Cards are visible when:
    // 1. Game is over (show all)
    // 2. Player has folded (show their cards)
    // 3. It's the human player's own cards (always show to themselves)
    // 4. Showdown round (show all)
    // 5. All players are all-in (show all)
    // 6. Human has no chips (show all)

    final bool shouldShowCards =
        _game!.isGameOver || // Game finished
        isFolded || // Player folded
        isHuman || // Human player's own cards
        _game!.currentRound == BettingRound.showdown || // Showdown round
        _game!.areAllActivePlayersAllIn || // All players all-in
        _humanPlayer?.chips == 0; // Human has no chips

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 360 ? 22.0 : 26.0;
    final cardHeight = screenWidth < 360 ? 32.0 : 38.0;

    // Only show loading border for human player's turn when they have chips
    final bool showLoadingBorder =
        isCurrentPlayer &&
        isHuman &&
        !isFolded &&
        !isAllIn &&
        !_game!.isGameOver &&
        _humanPlayer!.chips > 0;

    return GestureDetector(
      onTap: () => _selectPlayer(index),
      child: Stack(
        children: [
          // Main card container
          Container(
            width: 85,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isCurrentPlayer
                    ? Colors.amber
                    : isAllIn
                    ? Colors.orange
                    : Colors.white.withOpacity(0.2),
                width: isCurrentPlayer ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name and chips row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        player.name.length > 5
                            ? '${player.name.substring(0, 4)}...'
                            : player.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: isHuman ? Colors.blue.shade200 : Colors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          decoration: isFolded
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '\$${player.chips.toInt()}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 8.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                // Current bet
                if (player.currentBet > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '\$${player.currentBet.toInt()}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 7.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                // Last action
                if (player.lastAction.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(
                      player.lastAction.length > 8
                          ? '${player.lastAction.substring(0, 7)}...'
                          : player.lastAction,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 7.0,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 2.0),

                // Cards - only show if shouldShowCards is true
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (player.cards.isNotEmpty)
                      Realistplaycard(
                        card: player.cards[0],
                        isHidden: !shouldShowCards,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    if (player.cards.length > 1) ...[
                      const SizedBox(width: 1.0),
                      Realistplaycard(
                        card: player.cards[1],
                        isHidden: !shouldShowCards,
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ],
                  ],
                ),

                // Status
                if (isAllIn)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'ALL IN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                // Timer indicator ONLY for human player's turn
                if (showLoadingBorder)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getProgressColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_secondsRemaining',
                          style: TextStyle(
                            color: _getProgressColor(),
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                // No chips indicator
                if (isHuman && player.chips <= 0 && !_game!.isGameOver)
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'NO CHIPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Loading border ONLY for human player's turn
          if (showLoadingBorder)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ProgressBorderPainter(
                    progress: _secondsRemaining / _autoFoldDuration,
                    color: _getProgressColor(),
                    strokeWidth: 2.5,
                    borderRadius: 8,
                  ),
                ),
              ),
            ),

          // Winner indicator
          if (_game!.isGameOver && _game!.winners.contains(player))
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),

          // Hidden card indicator - only shows when cards are hidden
          if (!shouldShowCards)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isAllIn ? 'ALL IN' : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isAllIn ? 6 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerHandDialog() {
    if (_selectedPlayer == null || _selectedPlayerHand == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPlayer!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          if (_selectedPlayer!.isFolded)
                            const Text(
                              'FOLDED',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_selectedPlayer!.isAllIn)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ALL-IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'PLAYER CARDS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedPlayer!.cards.isNotEmpty)
                      Realistplaycard(
                        card: _selectedPlayer!.cards[0],
                        width: 70,
                        height: 98,
                      ),
                    const SizedBox(width: 8),
                    if (_selectedPlayer!.cards.length > 1)
                      Realistplaycard(
                        card: _selectedPlayer!.cards[1],
                        width: 70,
                        height: 98,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'HAND STRENGTH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPlayerHand!.handRank,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (_game!.communityCards.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'COMMUNITY CARDS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: _game!.communityCards
                        .map(
                          (card) => Realistplaycard(
                            card: card,
                            width: 45,
                            height: 63,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showPlayerHandDialog = false;
                        _selectedPlayerIndex = null;
                        _selectedPlayer = null;
                        _selectedPlayerHand = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CLOSE',
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
          ),
        ),
      ),
    );
  }
}
