import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

/// Enum defining all possible card types in The Chain
enum ChainCardType {
  genesis,    // Position #1 - The beginning
  active,     // Regular active members
  currentUser, // The logged-in user
  tip,        // The active chain holder who can invite
  pending,    // Invitation sent, waiting to join
  ghost,      // Empty slot waiting for invitation
  wasted,     // Expired invitation
  milestone,  // Special positions (#100, #1000, etc.)
}

/// Unified person card component that handles all member types
/// This single component adapts its appearance based on the card type
class ChainMemberCard extends StatefulWidget {
  final String? displayName;
  final String? chainKey;
  final int position;
  final ChainCardType type;
  final DateTime? expiresAt; // For pending cards
  final DateTime? expiredAt; // For wasted cards
  final int? milestoneValue; // For milestone cards (100, 1000, etc.)
  final VoidCallback? onTap;
  final bool animate;

  const ChainMemberCard({
    super.key,
    required this.position,
    required this.type,
    this.displayName,
    this.chainKey,
    this.expiresAt,
    this.expiredAt,
    this.milestoneValue,
    this.onTap,
    this.animate = true,
  });

  @override
  State<ChainMemberCard> createState() => _ChainMemberCardState();
}

class _ChainMemberCardState extends State<ChainMemberCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for current user and TIP
    _pulseController = AnimationController(
      duration: Duration(seconds: widget.type == ChainCardType.tip ? 2 : 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: widget.type == ChainCardType.tip ? 1.05 : 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Glow animation for special cards
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation for ghost cards
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start animations based on card type
    if (widget.animate) {
      switch (widget.type) {
        case ChainCardType.currentUser:
        case ChainCardType.tip:
        case ChainCardType.genesis:
          _pulseController.repeat(reverse: true);
          _glowController.repeat(reverse: true);
          break;
        case ChainCardType.ghost:
          _shimmerController.repeat();
          break;
        case ChainCardType.milestone:
          _glowController.repeat(reverse: true);
          break;
        default:
          // No animation for other types
          break;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _glowController,
          _shimmerController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _shouldPulse() ? _pulseAnimation.value : 1.0,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: _buildDecoration(),
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  bool _shouldPulse() {
    return widget.animate && (
      widget.type == ChainCardType.currentUser ||
      widget.type == ChainCardType.tip ||
      widget.type == ChainCardType.genesis
    );
  }

  BoxDecoration _buildDecoration() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.15),
              const Color(0xFFFFA500).withOpacity(0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(
              const Color(0xFFFFD700),
              const Color(0xFFFFA500),
              _glowAnimation.value,
            )!.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(_glowAnimation.value * 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        );

      case ChainCardType.currentUser:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.2),
              const Color(0xFF5B21B6).withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(_glowAnimation.value * 0.5),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        );

      case ChainCardType.tip:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(
              const Color(0xFF10B981),
              const Color(0xFF00D4FF),
              _glowAnimation.value,
            )!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(_glowAnimation.value),
              blurRadius: 30,
              spreadRadius: 10,
            ),
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        );

      case ChainCardType.pending:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withOpacity(0.15),
              const Color(0xFFD97706).withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF59E0B).withOpacity(0.5),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        );

      case ChainCardType.ghost:
        return BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        );

      case ChainCardType.wasted:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEF4444).withOpacity(0.1),
              const Color(0xFFDC2626).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1,
          ),
        );

      case ChainCardType.milestone:
        final color = _getMilestoneColor();
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_glowAnimation.value * 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        );

      case ChainCardType.active:
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F2937).withOpacity(0.6),
              const Color(0xFF111827).withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        );
    }
  }

  Widget _buildContent() {
    if (widget.type == ChainCardType.ghost) {
      return _buildGhostContent();
    }

    if (widget.type == ChainCardType.tip) {
      return _buildTipContent();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildName(),
                const SizedBox(height: 8),
                _buildInfo(),
                if (_hasSpecialBadge()) ...[
                  const SizedBox(height: 8),
                  _buildSpecialBadge(),
                ],
              ],
            ),
          ),
          if (widget.type == ChainCardType.currentUser)
            _buildYouBadge(),
        ],
      ),
    );
  }

  Widget _buildGhostContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Stack(
          children: [
            // Shimmer effect
            if (widget.animate)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1, 0),
                          end: Alignment(1, 0),
                          transform: GradientRotation(_shimmerAnimation.value),
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.grey,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Waiting for invitation...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Position #${widget.position}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.grey.withOpacity(0.3),
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipContent() {
    return Stack(
      children: [
        // Animated background pattern
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: _ChainPatternPainter(
                animation: _glowController,
              ),
            ),
          ),
        ),
        // Main content
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.displayName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${widget.position}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.chainKey ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.yellow[300],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chain Tip - Can Invite',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.yellow[300],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.yellow[600]!, Colors.orange[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow[600]!.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'TIP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final colors = _getAvatarColors();
    final icon = _getAvatarIcon();

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: widget.type == ChainCardType.currentUser ||
                widget.type == ChainCardType.genesis
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: icon ?? Text(
          widget.displayName?.isNotEmpty ?? false
              ? widget.displayName![0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    final isDisabled = widget.type == ChainCardType.wasted;

    return Text(
      widget.displayName ?? 'Unknown',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDisabled ? Colors.white54 : Colors.white,
        letterSpacing: 0.5,
        decoration: isDisabled ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildInfo() {
    return Row(
      children: [
        // Position badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getPositionBadgeColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#${widget.position}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getPositionBadgeTextColor(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Chain key or status
        Flexible(
          child: Text(
            _getSecondaryText(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _getSecondaryTextColor(),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialBadge() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return Text(
          'THE BEGINNING',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFD700),
            letterSpacing: 1.5,
          ),
        );

      case ChainCardType.pending:
        return Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 14,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            Text(
              _getTimeRemaining(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        );

      case ChainCardType.wasted:
        return Row(
          children: [
            const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(width: 4),
            Text(
              'Expired ${_getTimeSince()}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        );

      case ChainCardType.milestone:
        return Row(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 16,
              color: Color(0xFFC0C0C0),
            ),
            const SizedBox(width: 4),
            Text(
              'MILESTONE #${widget.milestoneValue}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC0C0C0),
                letterSpacing: 1.2,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildYouBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Text(
        'YOU',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Helper methods
  List<Color> _getAvatarColors() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case ChainCardType.currentUser:
        return [const Color(0xFF7C3AED), const Color(0xFF5B21B6)];
      case ChainCardType.tip:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case ChainCardType.pending:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case ChainCardType.wasted:
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case ChainCardType.milestone:
        return [_getMilestoneColor(), _getMilestoneColor().withOpacity(0.8)];
      default:
        return [const Color(0xFF4B5563), const Color(0xFF374151)];
    }
  }

  Widget? _getAvatarIcon() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return const Text('🌱', style: TextStyle(fontSize: 28));
      case ChainCardType.pending:
        return const Icon(Icons.access_time, color: Colors.white, size: 28);
      case ChainCardType.wasted:
        return const Icon(Icons.close, color: Colors.white, size: 28);
      case ChainCardType.milestone:
        return const Text('🏆', style: TextStyle(fontSize: 28));
      case ChainCardType.tip:
        return const Icon(Icons.trending_up, color: Colors.white, size: 28);
      default:
        return null;
    }
  }

  Color _getPositionBadgeColor() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return const Color(0xFFFFD700);
      case ChainCardType.currentUser:
        return const Color(0xFF7C3AED);
      case ChainCardType.tip:
        return Colors.white.withOpacity(0.2);
      case ChainCardType.milestone:
        return const Color(0xFFC0C0C0);
      default:
        return const Color(0xFF374151);
    }
  }

  Color _getPositionBadgeTextColor() {
    switch (widget.type) {
      case ChainCardType.genesis:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  String _getSecondaryText() {
    switch (widget.type) {
      case ChainCardType.pending:
        return 'Invitation Sent';
      case ChainCardType.wasted:
        return 'Invitation Expired';
      default:
        return widget.chainKey ?? 'CHAIN-------';
    }
  }

  Color _getSecondaryTextColor() {
    switch (widget.type) {
      case ChainCardType.pending:
        return const Color(0xFFF59E0B);
      case ChainCardType.wasted:
        return const Color(0xFFEF4444);
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  Color _getMilestoneColor() {
    if (widget.milestoneValue == null) return const Color(0xFFC0C0C0);
    if (widget.milestoneValue! >= 10000) return const Color(0xFFE5E4E2); // Platinum
    if (widget.milestoneValue! >= 1000) return const Color(0xFFFFD700); // Gold
    return const Color(0xFFC0C0C0); // Silver
  }

  bool _hasSpecialBadge() {
    return widget.type == ChainCardType.genesis ||
           widget.type == ChainCardType.pending ||
           widget.type == ChainCardType.wasted ||
           widget.type == ChainCardType.milestone;
  }

  String _getTimeRemaining() {
    if (widget.expiresAt == null) return '';
    final remaining = widget.expiresAt!.difference(DateTime.now());
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    }
    return '${remaining.inMinutes}m remaining';
  }

  String _getTimeSince() {
    if (widget.expiredAt == null) return 'recently';
    final since = DateTime.now().difference(widget.expiredAt!);
    if (since.inDays > 0) {
      return '${since.inDays}d ago';
    }
    if (since.inHours > 0) {
      return '${since.inHours}h ago';
    }
    return '${since.inMinutes}m ago';
  }
}

// Custom painter for animated chain pattern (used in TIP card)
class _ChainPatternPainter extends CustomPainter {
  final Animation<double> animation;

  _ChainPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final offset = animation.value * 50;

    // Draw animated chain links pattern
    for (double y = -50; y < size.height + 50; y += 30) {
      final path = Path();
      path.moveTo(0, y + offset);

      for (double x = 0; x < size.width; x += 40) {
        path.quadraticBezierTo(
          x + 10, y + 10 + offset,
          x + 20, y + offset,
        );
        path.quadraticBezierTo(
          x + 30, y - 10 + offset,
          x + 40, y + offset,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}