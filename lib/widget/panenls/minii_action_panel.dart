import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';

class MiniiActionPanel extends StatefulWidget {
  final double currentBet;
  final double playerCurrentBet;
  final bool isCheckAvailable;
  final bool isCallAvailable;
  final bool isRaiseAvailable;
  final Duration autoFoldDuration;
  final double playerChips;
  final VoidCallback onAutoFold;
  final void Function(GameAction action, double? raiseTo) onActionSelected;

  const MiniiActionPanel({
    super.key,
    required this.onActionSelected,
    required this.playerChips,
    required this.currentBet,
    required this.playerCurrentBet,
    required this.isCheckAvailable,
    required this.isCallAvailable,
    required this.isRaiseAvailable,
    this.autoFoldDuration = const Duration(seconds: 12),
    required this.onAutoFold,
  });

  @override
  State<MiniiActionPanel> createState() => _MiniiActionPanelState();
}

class _MiniiActionPanelState extends State<MiniiActionPanel>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulse;
  int _secLeft = 12;
  bool _urgent = false;

  @override
  void initState() {
    super.initState();
    _secLeft = widget.autoFoldDuration.inSeconds;
    _startTimer();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _secLeft = widget.autoFoldDuration.inSeconds;
    _urgent = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _secLeft--;
        if (_secLeft <= 4) _urgent = true;
      });
      if (_secLeft <= 0) {
        t.cancel();
        _pulse.stop();
        widget.onAutoFold();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _perform(GameAction action, [double? raiseTo]) {
    _timer.cancel();
    _pulse.stop();
    widget.onActionSelected(action, raiseTo);
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _secLeft / widget.autoFoldDuration.inSeconds.clamp(1, double.infinity);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // deeper, cleaner dark
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer – cleaner, more legible
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation(
                      _urgent
                          ? const Color(0xFFFF5555)
                          : const Color(0xFF2DD4BF),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final scale = _urgent ? 1.0 + _pulse.value * 0.1 : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          '$_secLeft',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: _urgent
                                ? const Color(0xFFFF7777)
                                : const Color(0xFF5EEAD4),
                            height: 1,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Buttons – cleaner spacing, flatter, more readable
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _smallButton(
                  'FOLD',
                  Colors.red.shade900,
                  () => _perform(GameAction.fold),
                  true,
                ),
                _smallButton(
                  'CHECK',
                  Colors.grey.shade800,
                  () => _perform(GameAction.check),
                  widget.isCheckAvailable,
                ),
                _smallButton(
                  'CALL',
                  Colors.blue.shade900,
                  () => _perform(GameAction.call),
                  widget.isCallAvailable,
                  extra: widget.currentBet > widget.playerCurrentBet
                      ? '${(widget.currentBet - widget.playerCurrentBet).toInt()}'
                      : null,
                ),
                _smallButton(
                  'RAISE',
                  Colors.green.shade900,
                  () => _perform(GameAction.raise),
                  widget.isRaiseAvailable,
                  accent: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallButton(
    String label,
    Color color,
    VoidCallback? onTap,
    bool enabled, {
    String? extra,
    bool accent = false,
  }) {
    final canPress = enabled && onTap != null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Opacity(
          opacity: canPress ? 1.0 : 0.4,
          child: ElevatedButton(
            onPressed: canPress ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade900,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(0, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: accent
                    ? BorderSide(color: Colors.white.withOpacity(0.2), width: 1)
                    : BorderSide.none,
              ),
              elevation: accent ? 2 : 0,
              shadowColor: accent ? Colors.white.withOpacity(0.1) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: accent ? 15 : 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                if (extra != null)
                  Text(
                    extra,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
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
