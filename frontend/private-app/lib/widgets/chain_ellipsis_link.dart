import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget that shows a compressed section of the chain with member count
/// Used when there are too many members to display all at once
class ChainEllipsisLink extends StatefulWidget {
  final int memberCount;
  final bool isAbove; // true if this represents members above, false for below
  final int startPosition;
  final int endPosition;
  final VoidCallback? onTap;

  const ChainEllipsisLink({
    super.key,
    required this.memberCount,
    required this.isAbove,
    required this.startPosition,
    required this.endPosition,
    this.onTap,
  });

  @override
  State<ChainEllipsisLink> createState() => _ChainEllipsisLinkState();
}

class _ChainEllipsisLinkState extends State<ChainEllipsisLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        constraints: const BoxConstraints(maxWidth: 400),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Dotted line with gradient
                _buildDottedLine(),

                // Member count badge
                _buildMemberCountBadge(),

                // Position range indicator
                if (widget.onTap != null) _buildExpandHint(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDottedLine() {
    return CustomPaint(
      size: const Size(2, 80),
      painter: _DottedLinePainter(
        fadeAnimation: _fadeAnimation,
        isAbove: widget.isAbove,
      ),
    );
  }

  Widget _buildMemberCountBadge() {
    return Transform.scale(
      scale: _pulseAnimation.value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F2937).withOpacity(0.9),
              const Color(0xFF111827).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(_fadeAnimation.value),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(_fadeAnimation.value * 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots icon
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7C3AED).withOpacity(
                        0.4 + (i * 0.2) + (_fadeAnimation.value * 0.2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Member count text
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.memberCount} members',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '#${widget.startPosition} - #${widget.endPosition}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Direction arrow
            Icon(
              widget.isAbove ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF7C3AED).withOpacity(_fadeAnimation.value),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandHint() {
    return Positioned(
      right: 0,
      child: Opacity(
        opacity: _fadeAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Tap to explore',
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the dotted line with gradient
class _DottedLinePainter extends CustomPainter {
  final Animation<double> fadeAnimation;
  final bool isAbove;

  _DottedLinePainter({
    required this.fadeAnimation,
    required this.isAbove,
  }) : super(repaint: fadeAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 5.0;
    double currentY = isAbove ? size.height : 0;

    // Create gradient effect
    while (isAbove ? currentY > 0 : currentY < size.height) {
      // Calculate opacity based on position
      double distanceFromCenter = (currentY - size.height / 2).abs();
      double normalizedDistance = distanceFromCenter / (size.height / 2);
      double opacity = (1 - normalizedDistance) * fadeAnimation.value;

      paint.color = const Color(0xFF7C3AED).withOpacity(opacity.clamp(0.1, 0.6));

      // Draw dash
      if (isAbove) {
        canvas.drawLine(
          Offset(size.width / 2, currentY),
          Offset(size.width / 2, math.max(0, currentY - dashHeight)),
          paint,
        );
        currentY -= (dashHeight + dashSpace);
      } else {
        canvas.drawLine(
          Offset(size.width / 2, currentY),
          Offset(size.width / 2, math.min(size.height, currentY + dashHeight)),
          paint,
        );
        currentY += (dashHeight + dashSpace);
      }
    }

    // Add glow effect at the center
    final glowPaint = Paint()
      ..color = const Color(0xFF7C3AED).withOpacity(0.2 * fadeAnimation.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      8,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Helper widget for showing the chain ellipsis in context
class ChainEllipsisSection extends StatelessWidget {
  final int hiddenMembersAbove;
  final int hiddenMembersBelow;
  final int currentPosition;
  final VoidCallback? onExpandAbove;
  final VoidCallback? onExpandBelow;

  const ChainEllipsisSection({
    super.key,
    this.hiddenMembersAbove = 0,
    this.hiddenMembersBelow = 0,
    required this.currentPosition,
    this.onExpandAbove,
    this.onExpandBelow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hiddenMembersAbove > 0)
          ChainEllipsisLink(
            memberCount: hiddenMembersAbove,
            isAbove: true,
            startPosition: 1,
            endPosition: currentPosition - 3,
            onTap: onExpandAbove,
          ),

        // Main chain visualization would go here

        if (hiddenMembersBelow > 0)
          ChainEllipsisLink(
            memberCount: hiddenMembersBelow,
            isAbove: false,
            startPosition: currentPosition + 3,
            endPosition: currentPosition + 2 + hiddenMembersBelow,
            onTap: onExpandBelow,
          ),
      ],
    );
  }
}