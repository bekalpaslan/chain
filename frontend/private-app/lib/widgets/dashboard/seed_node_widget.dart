import 'package:flutter/material.dart';
import 'package:thechain_shared/models/user.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

/// Seed node widget - displays the genesis user at the top of the chain
class SeedNodeWidget extends StatefulWidget {
  final User user;
  final VoidCallback? onTap;

  const SeedNodeWidget({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  State<SeedNodeWidget> createState() => _SeedNodeWidgetState();
}

class _SeedNodeWidgetState extends State<SeedNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800), // Faster pulse
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main node with pulsing glow effect
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 360,
                    height: 120, // 3x size, maintaining 1:3 ratio (360:120)
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          theme.gold.withOpacity(0.3),
                          theme.gold.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: theme.gold,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.gold.withOpacity(0.3 * _pulseAnimation.value),
                          blurRadius: 30 * _pulseAnimation.value,
                          spreadRadius: 5 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left 1/3 - Chain position
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              '#${widget.user.position}',
                              style: TextStyle(
                                color: theme.gold,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Right 2/3 - Full display name for current user (seed)
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                widget.user.displayName,
                                style: TextStyle(
                                  color: theme.gold,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
