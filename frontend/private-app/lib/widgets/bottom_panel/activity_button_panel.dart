import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

/// Activity button component for bottom panel
class ActivityButtonPanel extends StatefulWidget {
  final VoidCallback onTap;

  const ActivityButtonPanel({
    super.key,
    required this.onTap,
  });

  @override
  State<ActivityButtonPanel> createState() => _ActivityButtonPanelState();
}

class _ActivityButtonPanelState extends State<ActivityButtonPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for the activity indicator
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPressed
                    ? [
                        theme.mysticViolet.withOpacity(0.25),
                        theme.shadowDark.withOpacity(0.8),
                      ]
                    : [
                        theme.mysticViolet.withOpacity(0.2),
                        theme.shadowDark.withOpacity(0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.mysticViolet.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.mysticViolet.withOpacity(0.2),
                  blurRadius: _isPressed ? 5 : 15,
                  spreadRadius: _isPressed ? 0 : 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated pulse rings
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.mysticViolet.withOpacity(0.3 * (1 - _pulseAnimation.value)),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.emerald,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.emerald.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Activity waves background
                Positioned(
                  left: -20,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.rotate(
                      angle: _pulseAnimation.value * math.pi * 0.1,
                      child: Icon(
                        Icons.timeline,
                        size: 80,
                        color: theme.mysticViolet.withOpacity(0.05),
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.mysticViolet.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.show_chart,
                              color: theme.mysticViolet,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ACTIVITY',
                        style: TextStyle(
                          color: theme.mysticViolet,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      // Live indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.emerald,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: theme.emerald.withOpacity(0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
