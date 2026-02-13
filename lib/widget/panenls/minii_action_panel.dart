import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';

class MiniiActionPanel extends StatefulWidget {
  final double crrentBet;
  final double playerCurrentBet;
  final bool isCheck;
  final bool isCall;
  final bool isRaise;
  final Duration autonFoldDuration;
  final Function() onAutonFold;
  final Function(GameAction, double) onActionSelected;

  const MiniiActionPanel({
    super.key,
    required this.onActionSelected,
    required this.crrentBet,
    required this.playerCurrentBet,
    required this.isCheck,
    required this.isCall,
    required this.isRaise,
    this.autonFoldDuration = const Duration(seconds: 15),
    required this.onAutonFold,
  });

  @override
  State<MiniiActionPanel> createState() => _MiniiActionPanelState();
}

class _MiniiActionPanelState extends State<MiniiActionPanel> {
  late Timer _autoFold;
  int _scondsRamaining = 15;

  @override
  void initState() {
    super.initState();
    _startAutoFold();
  }

  void _startAutoFold() {
    _scondsRamaining = widget.autonFoldDuration.inSeconds;
    _autoFold = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _scondsRamaining--;
      });
      if (_scondsRamaining <= 0) {
        timer.cancel();
        widget.onAutonFold();
      }
    });
  }

  void _resetTime() {
    _autoFold.cancel();
    _startAutoFold();
  }

  void _selectAction(GameAction action, [double? raiseAmount]) {
    _autoFold.cancel();
    widget.onActionSelected(action, raiseAmount!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [Icon(Icons.timer), Text('$_scondsRamaining')],
            ),
          ),
          Row(
            children: [
              _control('FOLD', Colors.red.shade400),
              const SizedBox(width: 8),
              _control('CHECK', Colors.grey.shade600),
              const SizedBox(width: 8),
              _control('CALL', Colors.blue.shade400),
              const SizedBox(width: 8),
              _control('RAISE', Colors.green.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _control(String txt, Color clr) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: clr,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          txt,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
