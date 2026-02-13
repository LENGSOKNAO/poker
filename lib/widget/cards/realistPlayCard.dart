import 'dart:math';
import 'package:flutter/material.dart';

class Realistplaycard extends StatefulWidget {
  final dynamic card; // CardModel
  final bool isHidden;
  final double width;
  final double height;
  final bool dealAnimation;
  final Duration animationDelay;
  final bool flipAnimation;
  final bool useNetworkImage; // Switch between network and asset images

  const Realistplaycard({
    super.key,
    required this.card,
    this.isHidden = false,
    this.width = 80,
    this.height = 110,
    this.dealAnimation = false,
    this.animationDelay = Duration.zero,
    this.flipAnimation = false,
    this.useNetworkImage = true, // Default to network images
  });

  @override
  State<Realistplaycard> createState() => _RealistplaycardState();
}

class _RealistplaycardState extends State<Realistplaycard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      ),
      child: widget.isHidden ? _buildCardBack() : _buildCardFaceUp(),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/cards/card_back.png',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultCardBack();
          },
        ),
      ),
    );
  }

  Widget _buildDefaultCardBack() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Container(
          width: widget.width * 0.8,
          height: widget.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: widget.width * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFaceUp() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.useNetworkImage ? _buildNetworkCard() : _buildAssetCard(),
      ),
    );
  }

  Widget _buildNetworkCard() {
    return Image.network(
      widget.card.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SizedBox(
              width: widget.width * 0.3,
              height: widget.width * 0.3,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: widget.card.color,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackCard();
      },
    );
  }

  Widget _buildAssetCard() {
    return Image.asset(
      widget.card.imagePath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackCard();
      },
    );
  }

  Widget _buildFallbackCard() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.rankText,
                  style: TextStyle(
                    fontSize: widget.width * 0.18,
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
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Transform.rotate(
              angle: pi,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.rankText,
                    style: TextStyle(
                      fontSize: widget.width * 0.18,
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
              ),
            ),
          ),
          Center(
            child: Text(
              widget.card.isFaceCard
                  ? widget.card.faceCardSymbol
                  : widget.card.suitSymbol,
              style: TextStyle(
                fontSize: widget.width * 0.4,
                fontWeight: FontWeight.bold,
                color: widget.card.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
