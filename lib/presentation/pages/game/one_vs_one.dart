import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _betController.text = '500';

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

    if (bet < 500) {
      _showError('Insufficient balance! You need 500 to play.');
      return;
    }

    final actualBet = bet > user.balance ? user.balance : bet;

    user.balance -= actualBet;
    await _dataManager.updateUser(user);

    _game = PokerGame([user.name, "Opponent"], actualBet, numPlayers: 2);

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

    // If player clicks fold, immediately give pot to opponent
    if (action == GameAction.fold) {
      setState(() {
        player.isFolded = true;

        // Find the other player (opponent)
        final opponent = _game!.players.firstWhere((p) => p != player);

        // Give the entire pot to the opponent
        opponent.chips += _game!.pot;

        // Mark game as over
        _game!.isGameOver = true;
        _game!.winners = [opponent];
      });

      _updateBalanceFromGame();
      return;
    }

    // Normal game flow for other actions
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

    final aiPlayer = _game!.players.firstWhere((p) => p.isAI);

    if (aiPlayer.isFolded) return;

    double currentPot = _game!.pot;

    setState(() {
      _game!.makeAIAction();
    });

    if (aiPlayer.isFolded) {
      setState(() {
        _humanPlayer!.chips += currentPot;
        _game!.isGameOver = true;
        _game!.winners = [_humanPlayer!];
      });
      _updateBalanceFromGame();
      return;
    }

    if (aiPlayer.chips <= 0) {
      setState(() {
        aiPlayer.chips = 1000;
        _humanPlayer!.chips += _game!.pot;
        _game!.isGameOver = true;
        _game!.winners = [_humanPlayer!];
      });
      _updateBalanceFromGame();
      return;
    }

    if (!_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex].isAI &&
        !_game!.players[_game!.currentPlayerIndex].isFolded) {
      _handleAIAction();
    }
  }

  void _updateBalanceFromGame() {
    final user = _dataManager.currentUser;
    if (user != null && _humanPlayer != null) {
      user.balance = _humanPlayer!.chips;
      _dataManager.updateUser(user);
    }
  }

  void _startNewRound() {
    if (!mounted || _game == null || _humanPlayer == null) return;

    final humanChips = _humanPlayer!.chips;
    final oppChips = _game!.players[1].chips;

    _game = PokerGame(
      [_humanPlayer!.name, "Opponent"],
      humanChips,
      numPlayers: 2,
    );
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    _humanPlayer!.chips = humanChips;
    _game!.players[1].chips = oppChips;

    setState(() {});
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
                    children: [500, 1000, 5000, 10000].map((val) {
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

    final bool hasChips =
        _humanPlayer?.chips != null && _humanPlayer!.chips > 0;

    final bool canMakeAction =
        hasChips &&
        (_humanPlayer!.canCheck(_game!.currentBet) ||
            _humanPlayer!.canCall(_game!.currentBet) ||
            (_humanPlayer!.chips > 0 &&
                _humanPlayer!.canRaise(
                  _game!.currentBet + 20.0,
                  _game!.currentBet,
                )));

    final bool showActionPanel =
        !_game!.isGameOver &&
        _game!.players[_game!.currentPlayerIndex] == _humanPlayer &&
        !_humanPlayer!.isFolded &&
        !_humanPlayer!.isAllIn &&
        canMakeAction;

    String infoMessage = '';
    Color infoColor = Colors.grey;

    if (_game!.isGameOver) {
      if (_game!.winners.isNotEmpty) {
        final winner = _game!.winners.first;
        infoMessage = winner == _humanPlayer ? 'YOU WIN!' : 'OPPONENT WINS';
        infoColor = winner == _humanPlayer
            ? Colors.green[600]!
            : Colors.red[700]!;
      } else {
        infoMessage = 'GAME OVER';
        infoColor = Colors.grey[600]!;
      }
    } else if (!hasChips) {
      infoMessage = '⚠️ NO CHIPS LEFT ⚠️';
      infoColor = Colors.red[700]!;
    } else if (!canMakeAction && hasChips) {
      infoMessage = '⚠️ CANNOT MAKE ACTION ⚠️';
      infoColor = Colors.orange[800]!;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
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
                if (_game!.isGameOver ||
                    !hasChips ||
                    !canMakeAction ||
                    _game!.winners.isNotEmpty ||
                    _game!.winners.isEmpty)
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
                  const SizedBox(width: 36.0),
              ],
            ),
          ),

          if (infoMessage.isNotEmpty)
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    infoMessage,
                    style: TextStyle(
                      color: infoColor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),

                  if (_game!.isGameOver) ...[
                    const SizedBox(width: 8.0),
                    Text(
                      '\$${_game!.pot.toInt()}',
                      style: TextStyle(
                        color: infoColor,
                        fontSize: 15.0,
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
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 10,
                  child: SizedBox(
                    width: 150,
                    child: Center(
                      child: _playerCard(
                        name: 'OPPONENT',
                        chips: opp.chips,
                        action: opp.lastAction,
                        cards: opp.cards,
                        isOpponent: true,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${_game!.pot.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                                width: 58,
                                height: 82,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.10),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 4,
                                      sigmaY: 4,
                                    ), // requires import 'dart:ui'
                                    child: Container(
                                      color: Colors.white.withOpacity(0.03),
                                      child: Center(
                                        child: Icon(
                                          Icons.casino_rounded,
                                          size: 28,
                                          color: Colors.white.withOpacity(0.22),
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
                Positioned(
                  top: 0,
                  right: 10,
                  bottom: 0,
                  child: SizedBox(
                    width: 150,
                    child: Center(
                      child: _playerCard(
                        name: 'YOU',
                        chips: _humanPlayer?.chips ?? 0.0,
                        action: _humanPlayer?.lastAction ?? '',
                        cards: _humanPlayer?.cards ?? [],
                        isOpponent: false,
                        callAmount: call,
                      ),
                    ),
                  ),
                ),

                if (_game!.isGameOver || !hasChips || !canMakeAction)
                  Positioned(
                    bottom: 0, // ← give some breathing room from edge
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          // Optional: real blur (requires import 'dart:ui')
                          // backdropFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _startNewRound,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            'PLAY AGAIN',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showActionPanel)
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: MiniiActionPanel(
                      key: ValueKey(
                        'action_panel_${_game!.currentPlayerIndex}_${_game!.currentRound}',
                      ),
                      onActionSelected: (action, raiseAmount) {
                        _makeAction(action, raiseAmount: raiseAmount);
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
                      onAutoFold: () {
                        _makeAction(GameAction.fold);
                      },
                      playerChips: _humanPlayer!.chips,
                    ),
                  ),
              ],
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
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 360 ? 12.0 : 13.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
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
