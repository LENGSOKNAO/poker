import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';
import 'package:game_poker/widget/dialog/action_selection_dialog.dart';

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
  late Timer _autoFoldTimer;
  int _secondsRemaining = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.autoFoldDuration.inSeconds;
    _startAutoFoldTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAutoFoldTimer() {
    _autoFoldTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isDisposed) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        timer.cancel();
        if (mounted && !_isDisposed) {
          widget.onAutoFold();
        }
      }
    });
  }

  void _resetTimer() {
    if (_autoFoldTimer.isActive) {
      _autoFoldTimer.cancel();
    }
    setState(() {
      _secondsRemaining = widget.autoFoldDuration.inSeconds;
    });
    _startAutoFoldTimer();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoFoldTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectAction(GameAction action, [double? raiseAmount]) {
    if (_autoFoldTimer.isActive) {
      _autoFoldTimer.cancel();
    }
    widget.onActionSelected(action, raiseAmount);
  }

  bool get _isUrgent => _secondsRemaining <= 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value:
                        _secondsRemaining / widget.autoFoldDuration.inSeconds,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isUrgent
                          ? const Color(0xFFFF5555)
                          : const Color(0xFF2DD4BF),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, child) {
                      final scale = _isUrgent
                          ? 1.0 + _pulseAnimation.value * 0.1
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          '$_secondsRemaining',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: _isUrgent
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

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  label: 'FOLD',
                  color: Colors.red.shade900,
                  onTap: () => _selectAction(GameAction.fold),
                  enabled: true,
                ),
                _buildActionButton(
                  label: 'CHECK',
                  color: Colors.grey.shade800,
                  onTap: () => _selectAction(GameAction.check),
                  enabled: widget.isCheckAvailable,
                ),
                _buildActionButton(
                  label: 'CALL',
                  color: Colors.blue.shade900,
                  onTap: () => _selectAction(GameAction.call),
                  enabled: widget.isCallAvailable,
                  extra: widget.currentBet > widget.playerCurrentBet
                      ? '${(widget.currentBet - widget.playerCurrentBet).toInt()}'
                      : null,
                ),
                _buildActionButton(
                  label: 'RAISE',
                  color: Colors.green.shade900,
                  onTap: () => _showRaiseDialog(),
                  enabled: widget.isRaiseAvailable,
                  accent: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool enabled,
    String? extra,
    bool accent = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: enabled ? color : Colors.grey.shade800,
          child: InkWell(
            onTap: enabled
                ? () {
                    _resetTimer();
                    onTap();
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: accent
                    ? Border.all(color: Colors.white.withOpacity(0.2), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: accent ? 15 : 14,
                      fontWeight: FontWeight.w800,
                      color: enabled ? Colors.white : Colors.white54,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (extra != null && enabled)
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
      ),
    );
  }

  void _showRaiseDialog() {
    _resetTimer();
    showDialog(
      context: context,
      builder: (context) => ActionSelectionDialog(
        onActionSelected: _selectAction,
        currentBet: widget.currentBet,
        playerCurrentBet: widget.playerCurrentBet,
        playerChips: widget.playerChips,
        canCheck: widget.isCheckAvailable,
        canCall: widget.isCallAvailable,
        canRaise: widget.isRaiseAvailable,
      ),
    );
  }
}
