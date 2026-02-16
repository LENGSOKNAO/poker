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

    return SingleChildScrollView(
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1E24),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Raise',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[300],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Current Bet',
                            value: widget.currentBet.toStringAsFixed(0),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Your Bet',
                            value: widget.playerCurrentBet.toStringAsFixed(0),
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'To Call',
                            value: callAmount.toStringAsFixed(0),
                            color: callAmount > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Your Chips',
                            value: widget.playerChips.toStringAsFixed(0),
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Input Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raise Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF252A34),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _errorMessage.isNotEmpty
                              ? Colors.red.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _raiseController,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (_) {
                                if (_errorMessage.isNotEmpty) {
                                  setState(() => _errorMessage = '');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Range Indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _buildRangeBadge(
                      label: 'MIN',
                      value: minRaise.toStringAsFixed(0),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildRangeBadge(
                      label: 'MAX',
                      value: maxRaise.toStringAsFixed(0),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        label: 'Confirm',
                        onPressed: () {
                          final text = _raiseController.text.trim();
                          if (text.isEmpty) {
                            setState(() => _errorMessage = 'Enter amount');
                            return;
                          }

                          final amount = double.tryParse(text);
                          if (amount == null || amount <= 0) {
                            setState(() => _errorMessage = 'Invalid amount');
                            return;
                          }

                          if (amount < minRaise) {
                            setState(() {
                              _errorMessage =
                                  'Minimum: \$${minRaise.toStringAsFixed(0)}';
                            });
                            return;
                          }

                          if (amount > maxRaise) {
                            setState(
                              () => _errorMessage = 'Insufficient chips',
                            );
                            return;
                          }

                          Navigator.pop(context);
                          widget.onActionSelected(GameAction.raise, amount);
                        },
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A34),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(
            '\$$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(width: 4),
          Text(
            '\$$value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : Colors.grey[400],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _raiseController.dispose();
    super.dispose();
  }
}
