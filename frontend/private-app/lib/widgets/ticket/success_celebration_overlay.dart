import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

/// Success celebration overlay shown when user successfully invites someone
/// Features confetti animation and success message
class SuccessCelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const SuccessCelebrationOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<SuccessCelebrationOverlay> createState() =>
      _SuccessCelebrationOverlayState();

  /// Show the celebration overlay
  static Future<void> show(BuildContext context) async {
    HapticFeedback.heavyImpact();

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => SuccessCelebrationOverlay(
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _SuccessCelebrationOverlayState extends State<SuccessCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  final List<_ConfettiParticle> _confetti = [];
  final int _confettiCount = 100;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateConfetti();
    _autoDismiss();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _scaleController.forward();
    _confettiController.forward();
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < _confettiCount; i++) {
      _confetti.add(_ConfettiParticle(
        color: _getRandomColor(random),
        x: random.nextDouble(),
        y: -0.1 - (random.nextDouble() * 0.2),
        size: 8 + random.nextDouble() * 12,
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
        velocityY: 0.3 + random.nextDouble() * 0.5,
        velocityX: (random.nextDouble() - 0.5) * 0.3,
      ));
    }
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF00D4FF), // Cyan
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6B9D), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _autoDismiss() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Confetti
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              size: size,
              painter: _ConfettiPainter(
                confetti: _confetti,
                progress: _confettiController.value,
              ),
            );
          },
        ),

        // Success dialog
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.mysticViolet.withOpacity(0.9),
                      theme.ghostCyan.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.mysticViolet.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon
                      _buildSuccessIcon(),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'SUCCESS!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Message
                      Text(
                        'You\'ve successfully invited someone to The Chain!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Reward message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re done!\nNo more tickets needed.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                color: AppTheme.darkMystique.emerald,
                size: 80,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final double velocityY;
  final double velocityX;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.velocityY,
    required this.velocityX,
  });
}

/// Custom painter for confetti animation
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in confetti) {
      // Calculate position based on progress
      final currentY = particle.y + (particle.velocityY * progress * size.height);
      final currentX = particle.x * size.width + (particle.velocityX * progress * size.width);
      final currentRotation = particle.rotation + (particle.rotationSpeed * progress * 2 * math.pi);

      // Skip if particle is off screen
      if (currentY > size.height + 20) continue;

      // Draw particle
      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Draw as rectangle (confetti piece)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(2)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
