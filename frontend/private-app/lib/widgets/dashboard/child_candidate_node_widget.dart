import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Child candidate node widget - displays a "+" button to invite new users
class ChildCandidateNodeWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const ChildCandidateNodeWidget({
    super.key,
    this.onTap,
  });

  @override
  State<ChildCandidateNodeWidget> createState() => _ChildCandidateNodeWidgetState();
}

class _ChildCandidateNodeWidgetState extends State<ChildCandidateNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
              // Connector line from parent
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.gold.withOpacity(0.5),
                      theme.gray600.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

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
                          theme.gray600.withOpacity(0.2),
                          theme.gray700.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: theme.gray600.withOpacity(0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.gray600.withOpacity(0.2 * _pulseAnimation.value),
                          blurRadius: 20 * _pulseAnimation.value,
                          spreadRadius: 3 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: theme.gray600,
                        size: 64,
                      ),
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
