import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

// Add Success Green constant
const Color successGreen = Color(0xFF10B981);

/// Brief overlay shown when a ticket expires
/// Displays strike count and auto-dismisses after a few seconds
class TicketExpiredOverlay extends StatefulWidget {
  final int newStrikeCount;
  final VoidCallback onDismiss;

  const TicketExpiredOverlay({
    super.key,
    required this.newStrikeCount,
    required this.onDismiss,
  });

  @override
  State<TicketExpiredOverlay> createState() => _TicketExpiredOverlayState();

  /// Show the overlay as a dialog
  static Future<void> show(
    BuildContext context, {
    required int newStrikeCount,
  }) async {
    HapticFeedback.heavyImpact();

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => TicketExpiredOverlay(
        newStrikeCount: newStrikeCount,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _TicketExpiredOverlayState extends State<TicketExpiredOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _autoDismiss();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  void _autoDismiss() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final isFinalStrike = widget.newStrikeCount >= 3;
    final severity = _getSeverity(widget.newStrikeCount);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      severity.backgroundColor.withOpacity(0.9),
                      severity.backgroundColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: severity.borderColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: severity.glowColor.withOpacity(_glowAnimation.value),
                      blurRadius: 40 * _glowAnimation.value,
                      spreadRadius: 8 * _glowAnimation.value,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Warning icon
                      _buildWarningIcon(severity),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'TICKET EXPIRED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Strike counter
                      _buildStrikeCounter(widget.newStrikeCount, severity),
                      const SizedBox(height: 24),

                      // Message
                      Text(
                        severity.message(widget.newStrikeCount),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (!isFinalStrike) ...[
                        const SizedBox(height: 24),
                        Text(
                          'A new ticket has been issued.',
                          style: TextStyle(
                            color: theme.ghostCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Dismiss button
                      ElevatedButton(
                        onPressed: widget.onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: severity.backgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon(_ExpiredSeverity severity) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          severity.icon,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }

  Widget _buildStrikeCounter(int count, _ExpiredSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'STRIKE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                ' / 3',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ExpiredSeverity _getSeverity(int strikeCount) {
    if (strikeCount >= 3) {
      return _ExpiredSeverity.critical;
    } else if (strikeCount >= 2) {
      return _ExpiredSeverity.high;
    } else {
      return _ExpiredSeverity.medium;
    }
  }
}

/// Severity levels for expired ticket overlay
enum _ExpiredSeverity {
  medium,
  high,
  critical;

  String message(int strikeCount) {
    switch (this) {
      case _ExpiredSeverity.medium:
        return 'Your ticket has expired without being used. This is your first strike.';
      case _ExpiredSeverity.high:
        return 'Your ticket has expired again. You now have $strikeCount strikes. One more and you\'ll be removed from The Chain!';
      case _ExpiredSeverity.critical:
        return 'You have reached 3 strikes and will be removed from The Chain. Thank you for participating.';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case _ExpiredSeverity.medium:
        return const Color(0xFFF59E0B); // Amber
      case _ExpiredSeverity.high:
        return const Color(0xFFF97316); // Orange
      case _ExpiredSeverity.critical:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get borderColor {
    switch (this) {
      case _ExpiredSeverity.medium:
        return const Color(0xFFFBBF24);
      case _ExpiredSeverity.high:
        return const Color(0xFFFB923C);
      case _ExpiredSeverity.critical:
        return const Color(0xFFF87171);
    }
  }

  Color get glowColor {
    switch (this) {
      case _ExpiredSeverity.medium:
        return const Color(0xFFF59E0B).withOpacity(0.5);
      case _ExpiredSeverity.high:
        return const Color(0xFFF97316).withOpacity(0.6);
      case _ExpiredSeverity.critical:
        return const Color(0xFFEF4444).withOpacity(0.8);
    }
  }

  IconData get icon {
    switch (this) {
      case _ExpiredSeverity.medium:
        return Icons.warning_amber_rounded;
      case _ExpiredSeverity.high:
        return Icons.error_outline;
      case _ExpiredSeverity.critical:
        return Icons.block;
    }
  }
}
