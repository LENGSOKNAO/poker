import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_poker/core/enums/game.enums.dart';

class ActionSelectionDialog extends StatefulWidget {
  final Function(GameAction, double?) onActionSelected;
  final double currentBet;
  final double playerCurrentBet;
  final double playerChips;
  final bool canCheck;
  final bool canCall;
  final bool canRaise;

  const ActionSelectionDialog({
    super.key,
    required this.onActionSelected,
    required this.currentBet,
    required this.playerCurrentBet,
    required this.playerChips,
    required this.canCheck,
    required this.canCall,
    required this.canRaise,
  });

  @override
  State<ActionSelectionDialog> createState() => _ActionSelectionDialogState();
}

class _ActionSelectionDialogState extends State<ActionSelectionDialog> {
  final TextEditingController _raiseController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final minRaise = _calculateMinRaise();
      _raiseController.text = minRaise.toStringAsFixed(0);
      _raiseController.selection = TextSelection.fromPosition(
        TextPosition(offset: _raiseController.text.length),
      );
    });
  }

  double _calculateMinRaise() {
    final callAmount = widget.currentBet - widget.playerCurrentBet;
    return max(widget.currentBet * 2, widget.currentBet + callAmount);
  }

  @override
  Widget build(BuildContext context) {
    final callAmount = widget.currentBet - widget.playerCurrentBet;
    final minRaise = _calculateMinRaise();
    final maxRaise = widget.playerChips + widget.playerCurrentBet;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raise Amount',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
            ),
            const SizedBox(height: 20),

            _infoRow('Current bet', widget.currentBet),
            _infoRow('Your bet', widget.playerCurrentBet),
            _infoRow(
              'To call',
              callAmount,
              color: callAmount > 0 ? Colors.red[700] : Colors.green[700],
            ),
            _infoRow('Your chips', widget.playerChips),
            const SizedBox(height: 28),

            Text(
              'Raise to',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _raiseController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '\$',
                prefixStyle: const TextStyle(fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              style: const TextStyle(fontSize: 24),
              onChanged: (_) {
                if (_errorMessage.isNotEmpty)
                  setState(() => _errorMessage = '');
              },
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: $minRaise',
                  style: TextStyle(color: Colors.orange[800], fontSize: 14),
                ),
                Text(
                  'Max: $maxRaise',
                  style: TextStyle(color: Colors.green[800], fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final text = _raiseController.text.trim();
                  if (text.isEmpty) {
                    setState(() => _errorMessage = 'Enter an amount');
                    return;
                  }

                  final amount = double.tryParse(text);
                  if (amount == null || amount <= 0) {
                    setState(() => _errorMessage = 'Invalid amount');
                    return;
                  }

                  if (amount < minRaise) {
                    setState(() {
                      _errorMessage = 'Minimum is $minRaise';
                    });
                    return;
                  }

                  if (amount > maxRaise) {
                    setState(() => _errorMessage = 'Not enough chips');
                    return;
                  }

                  Navigator.pop(context);
                  widget.onActionSelected(GameAction.raise, amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'CONFIRM RAISE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, double value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _raiseController.dispose();
    super.dispose();
  }
}
