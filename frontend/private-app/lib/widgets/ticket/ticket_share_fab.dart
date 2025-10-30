import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ticket_models.dart';
import '../../theme/app_theme.dart';

/// Floating Action Button for sharing the user's active ticket
/// Hidden when user has successfully invited someone (activeChildId != null)
class TicketShareFAB extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onPressed;

  const TicketShareFAB({
    super.key,
    required this.ticket,
    required this.onPressed,
  });

  @override
  State<TicketShareFAB> createState() => _TicketShareFABState();
}

class _TicketShareFABState extends State<TicketShareFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final animationSpeed = widget.ticket.urgency.animationSpeed;
    final pulseIntensity = widget.ticket.urgency.pulseIntensity;

    _pulseController = AnimationController(
      duration: Duration(milliseconds: (2000 / animationSpeed).round()),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + (0.1 * pulseIntensity),
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(TicketShareFAB oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation if urgency changed
    if (oldWidget.ticket.urgency != widget.ticket.urgency) {
      _pulseController.dispose();
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgency = widget.ticket.urgency;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: urgency.glowColor.withOpacity(_glowAnimation.value),
                  blurRadius: 24 * _glowAnimation.value,
                  spreadRadius: 8 * _glowAnimation.value,
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onPressed();
              },
              backgroundColor: urgency.colorStart,
              elevation: 8,
              icon: Icon(
                Icons.share,
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Share Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact circular FAB variant (for space-constrained layouts)
class TicketShareFABCompact extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onPressed;

  const TicketShareFABCompact({
    super.key,
    required this.ticket,
    required this.onPressed,
  });

  @override
  State<TicketShareFABCompact> createState() => _TicketShareFABCompactState();
}

class _TicketShareFABCompactState extends State<TicketShareFABCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final animationSpeed = widget.ticket.urgency.animationSpeed;
    final pulseIntensity = widget.ticket.urgency.pulseIntensity;

    _pulseController = AnimationController(
      duration: Duration(milliseconds: (2000 / animationSpeed).round()),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + (0.15 * pulseIntensity),
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(TicketShareFABCompact oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation if urgency changed
    if (oldWidget.ticket.urgency != widget.ticket.urgency) {
      _pulseController.dispose();
      _initializeAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgency = widget.ticket.urgency;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: urgency.glowColor.withOpacity(_glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 6 * _glowAnimation.value,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onPressed();
              },
              backgroundColor: urgency.colorStart,
              elevation: 8,
              child: Icon(
                Icons.share,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
