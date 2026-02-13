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
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Debug: Print card info
    if (widget.card != null) {
      print('🎴 Building card: ${widget.card.toString()}');
      print('📱 Using network: ${widget.useNetworkImage}');
      if (widget.useNetworkImage) {
        print('🔗 Image URL: ${widget.card.imageUrl}');
      } else {
        print('📁 Local path: ${widget.card.imagePath}');
      }
    } else {
      print('❌ ERROR: Card is null!');
    }

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
    // Check if card is null
    if (widget.card == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: widget.width * 0.3,
              ),
              Text(
                'No Card',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: widget.width * 0.15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading card back: $error');
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white70, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey[800]!,
            Colors.blueGrey[900]!,
            Colors.blueGrey[700]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style, color: Colors.white70, size: widget.width * 0.3),
            Text(
              'BACK',
              style: TextStyle(
                fontSize: widget.width * 0.2,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
          ],
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
        child: _hasError
            ? _buildFallbackCard()
            : (widget.useNetworkImage
                  ? _buildNetworkCard()
                  : _buildAssetCard()),
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
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.card?.color ?? Colors.blue,
              ),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        print('❌ Error loading network image: $error');
        print('🔗 Failed URL: $url');
        setState(() {
          _hasError = true;
        });
        return _buildFallbackCard();
      },
      fadeInDuration: const Duration(milliseconds: 400),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: (widget.width * 2).toInt(),
    );
  }

  Widget _buildAssetCard() {
    return Image.asset(
      widget.card.imagePath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading asset: ${widget.card.imagePath}');
        print('📁 Error details: $error');
        setState(() {
          _hasError = true;
        });
        return _buildFallbackCard();
      },
    );
  }

  Widget _buildFallbackCard() {
    final color = widget.card?.color ?? Colors.black;
    final rankText = widget.card?.rankText ?? '?';
    final suitSymbol = widget.card?.suitSymbol ?? '?';
    final isFaceCard = widget.card?.isFaceCard ?? false;
    final faceCardSymbol = widget.card?.faceCardSymbol ?? '?';

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
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
                  rankText,
                  style: TextStyle(
                    fontSize: widget.width * 0.20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 0.9,
                  ),
                ),
                Text(
                  suitSymbol,
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
              angle: 3.1415926535, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rankText,
                    style: TextStyle(
                      fontSize: widget.width * 0.20,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    suitSymbol,
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
              isFaceCard ? faceCardSymbol : suitSymbol,
              style: TextStyle(
                fontSize: widget.width * 0.45,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
          // Small indicator that this is fallback
          if (_hasError)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
