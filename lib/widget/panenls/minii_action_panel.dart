import 'dart:async';
import 'dart:math';
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  bigColor:
                      Colors.blueGrey.shade800, // uniform dark slate for all
                  smallColor: Colors.blueGrey.shade600,
                  label: 'FOLD',
                  color: Colors.blueGrey.shade800,
                  onTap: () => _selectAction(GameAction.fold),
                  enabled: true,
                ),
                _buildActionButton(
                  bigColor: Colors.blueGrey.shade800,
                  smallColor: Colors.blueGrey.shade600,
                  label: 'CHECK',
                  color: Colors.blueGrey.shade800,
                  onTap: () => _selectAction(GameAction.check),
                  enabled: widget.isCheckAvailable,
                ),
                _buildActionButton(
                  bigColor: Colors.blueGrey.shade800,
                  smallColor: Colors.blueGrey.shade600,
                  label: 'CALL',
                  color: Colors.blueGrey.shade800,
                  onTap: () => _selectAction(GameAction.call),
                  enabled: widget.isCallAvailable,
                  extra: widget.currentBet > widget.playerCurrentBet
                      ? '${(widget.currentBet - widget.playerCurrentBet).toInt()}'
                      : null,
                ),
                _buildActionButton(
                  bigColor: Colors.blueGrey.shade800,
                  smallColor: Colors.blueGrey.shade600,
                  label: 'RAISE',
                  color: Colors.blueGrey.shade800,
                  onTap: () => _showRaiseDialog(),
                  enabled: widget.isRaiseAvailable,
                  accent:
                      true, // optional: keep if Raise needs slight highlight (e.g. border/glow in your widget)
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
    required Color smallColor,
    required Color bigColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          children: [
            // Main button
            Material(
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
                        ? Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(width: 10),
                      if (extra != null && enabled)
                        Text(
                          '(\$$extra)',
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
            // Progress border
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ProgressBorderPainter(
                    progress:
                        _secondsRemaining / widget.autoFoldDuration.inSeconds,
                    color: _isUrgent ? smallColor : bigColor,
                    strokeWidth: 3,
                    borderRadius: 16,
                  ),
                ),
              ),
            ),
          ],
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

class ProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  ProgressBorderPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 3,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, backgroundPaint);

    // Progress border
    if (progress > 0) {
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
  }

  @override
  bool shouldRepaint(ProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
