import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Realistplaycard extends StatefulWidget {
  final dynamic card; // CardModel
  final bool isHidden;
  final double width;
  final double height;
  final bool dealAnimation;
  final Duration animationDelay;
  final bool flipAnimation;
  final bool
  useNetworkImage; // true = network (Deck of Cards API), false = local assets

  const Realistplaycard({
    super.key,
    required this.card,
    this.isHidden = false,
    this.width = 80,
    this.height = 110,
    this.dealAnimation = false,
    this.animationDelay = Duration.zero,
    this.flipAnimation = false,
    this.useNetworkImage = true,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/cards/card_back.png',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultCardBack(),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white70, width: 2),
      ),
      child: Center(
        child: Text(
          'BACK',
          style: TextStyle(
            fontSize: widget.width * 0.25,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1.5,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.useNetworkImage ? _buildNetworkCard() : _buildAssetCard(),
      ),
    );
  }

  Widget _buildNetworkCard() {
    return CachedNetworkImage(
      imageUrl: widget.card.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: SizedBox(
          width: widget.width * 0.4,
          height: widget.width * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(widget.card.color),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildFallbackCard(),
      fadeInDuration: const Duration(milliseconds: 400),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: (widget.width * 2).toInt(), // better quality on high-res
    );
  }

  Widget _buildAssetCard() {
    return Image.asset(
      widget.card.imagePath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackCard(),
    );
  }

  Widget _buildFallbackCard() {
    final color = widget.card.color;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.rankText,
                  style: TextStyle(
                    fontSize: widget.width * 0.20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 0.9,
                  ),
                ),
                Text(
                  widget.card.suitSymbol,
                  style: TextStyle(fontSize: widget.width * 0.16, color: color),
                ),
              ],
            ),
          ),
          // Bottom-right (rotated)
          Positioned(
            bottom: 8,
            right: 8,
            child: Transform.rotate(
              angle: 3.1415926535, // pi radians
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.rankText,
                    style: TextStyle(
                      fontSize: widget.width * 0.20,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    widget.card.suitSymbol,
                    style: TextStyle(
                      fontSize: widget.width * 0.16,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center symbol
          Center(
            child: Text(
              widget.card.isFaceCard
                  ? widget.card.faceCardSymbol
                  : widget.card.suitSymbol,
              style: TextStyle(
                fontSize: widget.width * 0.45,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
