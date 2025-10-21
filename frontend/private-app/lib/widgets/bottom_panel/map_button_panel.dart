import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Map button component for bottom panel
class MapButtonPanel extends StatefulWidget {
  final VoidCallback onTap;

  const MapButtonPanel({
    super.key,
    required this.onTap,
  });

  @override
  State<MapButtonPanel> createState() => _MapButtonPanelState();
}

class _MapButtonPanelState extends State<MapButtonPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                        theme.mysticViolet.withOpacity(0.15),
                      ]
                    : [
                        theme.mysticViolet.withOpacity(0.2),
                        theme.mysticViolet.withOpacity(0.1),
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
                // Animated background decoration
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.mysticViolet.withOpacity(0.1),
                          theme.mysticViolet.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.mysticViolet.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.explore,
                          color: theme.mysticViolet,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EXPLORE',
                        style: TextStyle(
                          color: theme.mysticViolet,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
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
