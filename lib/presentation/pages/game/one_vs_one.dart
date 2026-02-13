import 'package:flutter/material.dart';
import 'package:game_poker/core/app_size.dart';
import 'package:game_poker/data/game/poker_game.dart';
import 'package:game_poker/data/model/player.dart';
import 'package:game_poker/data/model/user.dart';
import 'package:game_poker/data/services/data_manager.dart';

class GameOneVsOne extends StatefulWidget {
  const GameOneVsOne({super.key});

  @override
  State<GameOneVsOne> createState() => _GameOneVsOneState();
}

class _GameOneVsOneState extends State<GameOneVsOne> {
  final TextEditingController _moneyController = TextEditingController();
  final DataManager _dataManager = DataManager();
  String _selectedChip = '1000';

  final List<Map<String, dynamic>> _chips = [
    {'value': '100', 'label': '100'},
    {'value': '500', 'label': '500'},
    {'value': '1000', 'label': '1K'},
    {'value': '5000', 'label': '5K'},
    {'value': '10000', 'label': '10K'},
    {'value': '25000', 'label': '25K'},
  ];

  PokerGame? _game;
  Player? _humanPlayer;
  bool _isGameActive = false;
  String _gameMessage = '';

  @override
  void initState() {
    super.initState();
    _moneyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  double get userBalance => _dataManager.currentUser?.balance ?? 0.0;

  void _addChipValue(String value) {
    final current =
        int.tryParse(_moneyController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    final add = int.parse(value);
    final newAmout = current + add;

    if (newAmout > userBalance.toInt()) {
      _moneyController.text = userBalance.toInt().toString();
    } else {
      _moneyController.text = newAmout.toString();
    }
  }

  void _startGame() async {
    final bet = double.tryParse(_moneyController.text);
    final user = _dataManager.currentUser;

    if (bet == null || bet <= 0) {
      _showMessage("Your bet amount is invalid. Please try again.");
      return;
    }

    if (user == null) {
      _showMessage("User not found. Please login again.");
      return;
    }

    user.balance -= bet;
    await _dataManager.updateUser(user);

    _game = PokerGame([user.name, "Player Ai"], bet, numPlayer: 2);
    _humanPlayer = _game!.players.firstWhere((p) => !p.isAI);

    setState(() {
      _isGameActive = true;
      _gameMessage = 'Game started';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _dataManager.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        title: const Text(
          '1 VS 1 TEXAS HOLD\'EM',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (!_isGameActive) ...[
            _buildSelectChip(user),
          ] else ...[
            _buildGameTable(),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectChip(User? user) {
    return Container(
      height: AppSize.heigth(context),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(
              0.48,
            ), // slightly lighter overlay so blue bg shines through
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chips + input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.68),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.20),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Chips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _moneyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.35),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Quick Select',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.45,
                ),
                itemCount: _chips.length,
                itemBuilder: (context, index) {
                  final chip = _chips[index];
                  final selected = _selectedChip == chip['value'];

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedChip = chip['value']);
                      _addChipValue(chip['value']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.shade600
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: selected
                            ? Border.all(
                                color: Colors.blue.shade400,
                                width: 1.5,
                              )
                            : Border.all(color: Colors.white.withOpacity(0.10)),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.40),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        chip['label'],
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallButton('Clear', Colors.red.shade800, () {
                      _moneyController.clear();
                      setState(() {});
                    }),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSmallButton(
                      'Max',
                      Colors.blue.shade700,
                      () => _moneyController.text = '1000000',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 34),

              // Balance
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.68),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.20),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${user?.balance}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              // Start Game
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'START GAME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGameTable() {
    if (_game == null) return Container();

    double callAmnount = _humanPlayer != null
        ? _game!.currentBet - _humanPlayer!.currentBet
        : 0;

    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: AppSize.heigth(context),
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}
