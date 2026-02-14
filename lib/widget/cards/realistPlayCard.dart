import 'package:flutter/material.dart';
import 'package:game_poker/data/model/card_model.dart';

class Realistplaycard extends StatefulWidget {
  final CardModel card;
  final bool isHidden;
  final double width;
  final double height;
  final bool dealAnimation;
  final Duration animationDelay;
  final bool flipAnimation;
  const Realistplaycard({
    super.key,
    required this.card,
    this.isHidden = false,
    this.width = 80,
    this.height = 110,
    this.dealAnimation = false,
    this.animationDelay = Duration.zero,
    this.flipAnimation = false,
  });

  @override
  State<Realistplaycard> createState() => _RealistplaycardState();
}

class _RealistplaycardState extends State<Realistplaycard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flipAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (widget.dealAnimation || widget.flipAnimation) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.dealAnimation ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.dealAnimation ? _fadeAnimation.value : 1.0,
            child: _buildFlipAnimation(),
          ),
        );
      },
    );
  }

  Widget _buildFlipAnimation() {
    if (!widget.flipAnimation) {
      return _buildCardContent();
    }

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isFront = _flipAnimation.value < 0.5;
        final rotationValue = isFront
            ? _flipAnimation.value * 2
            : (1 - (_flipAnimation.value - 0.5) * 2);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(3.14159 * (1 - rotationValue)),
          alignment: Alignment.center,
          child: isFront ? _buildCardContent() : _buildCardBack(),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.isHidden ? _buildCardBack() : _buildCardFace(),
      ),
    );
  }

  Widget _buildCardFace() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade100, Colors.grey.shade300],
        ),
      ),
      child: Stack(
        children: [
          // Center card value (for visual interest)
          if (widget.card.isFaceCard)
            Center(
              child: Text(
                widget.card.suitSymbol,
                style: TextStyle(
                  fontSize: widget.width * 0.4,
                  color: widget.card.color.withOpacity(0.2),
                ),
              ),
            ),

          // Top-left corner
          Positioned(top: 4, left: 4, child: _buildCornerSymbol()),

          // Bottom-right corner (rotated 180 degrees)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: _buildCornerSymbol(),
            ),
          ),

          // Center main symbol for non-face cards or additional style
          if (!widget.card.isFaceCard)
            Center(
              child: Text(
                widget.card.rankText,
                style: TextStyle(
                  fontSize: widget.width * 0.3,
                  fontWeight: FontWeight.bold,
                  color: widget.card.color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCornerSymbol() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.card.rankText,
          style: TextStyle(
            fontSize: widget.width * 0.15,
            fontWeight: FontWeight.bold,
            color: widget.card.color,
          ),
        ),
        Text(
          widget.card.suitSymbol,
          style: TextStyle(
            fontSize: widget.width * 0.15,
            color: widget.card.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a237e), // Dark blue
            Color(0xFF283593), // Medium blue
            Color(0xFF3949ab), // Lighter blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Diagonal pattern
          CustomPaint(
            painter: CardBackPatternPainter(),
            size: Size(widget.width, widget.height),
          ),

          // Center logo/design
          Center(
            child: Container(
              width: widget.width * 0.5,
              height: widget.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.credit_card,
                  color: Colors.white70,
                  size: widget.width * 0.2,
                ),
              ),
            ),
          ),

          // Decorative corner elements
          Positioned(
            top: 8,
            left: 8,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.3),
              size: widget.width * 0.1,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.3),
              size: widget.width * 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final spacing = size.width / 8;

    // Draw diagonal lines (top-left to bottom-right)
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      path.reset();
      path.moveTo(i, 0);
      path.lineTo(i + size.height, size.height);
      canvas.drawPath(path, paint);
    }

    // Draw opposite diagonal lines (top-right to bottom-left)
    for (double i = size.width + size.height; i > -size.height; i -= spacing) {
      path.reset();
      path.moveTo(i, 0);
      path.lineTo(i - size.height, size.height);
      canvas.drawPath(path, paint);
    }

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
