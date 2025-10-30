import 'package:flutter/material.dart';
import 'chain_card.dart';

/// A visual representation of the user's position in the chain
/// Shows parent, self, and child connections with animated effects
class ChainPositionVisualizer extends StatefulWidget {
  final String? parentName;
  final String? parentAvatar;
  final int? parentPosition;

  final String userName;
  final String userAvatar;
  final int userPosition;

  final String? childName;
  final String? childAvatar;
  final int? childPosition;

  final bool isCompact;
  final VoidCallback? onParentTap;
  final VoidCallback? onChildTap;
  final VoidCallback? onUserTap;

  const ChainPositionVisualizer({
    super.key,
    this.parentName,
    this.parentAvatar,
    this.parentPosition,
    required this.userName,
    required this.userAvatar,
    required this.userPosition,
    this.childName,
    this.childAvatar,
    this.childPosition,
    this.isCompact = false,
    this.onParentTap,
    this.onChildTap,
    this.onUserTap,
  });

  @override
  State<ChainPositionVisualizer> createState() => _ChainPositionVisualizerState();
}

class _ChainPositionVisualizerState extends State<ChainPositionVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _connectionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _connectionAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the user node
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Connection line animation
    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactView();
    }
    return _buildFullView();
  }

  Widget _buildFullView() {
    return ChainCard(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Connection lines
            AnimatedBuilder(
              animation: _connectionAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ChainConnectionPainter(
                    progress: _connectionAnimation.value,
                    hasParent: widget.parentName != null,
                    hasChild: widget.childName != null,
                  ),
                  child: Container(),
                );
              },
            ),
            // Nodes
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Parent node
                _buildNode(
                  name: widget.parentName ?? 'Genesis',
                  avatar: widget.parentAvatar ?? '🌟',
                  position: widget.parentPosition ?? 0,
                  isActive: widget.parentName != null,
                  onTap: widget.onParentTap,
                  label: 'PARENT',
                ),
                // User node (animated)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildNode(
                        name: widget.userName,
                        avatar: widget.userAvatar,
                        position: widget.userPosition,
                        isActive: true,
                        isUser: true,
                        onTap: widget.onUserTap,
                        label: 'YOU',
                      ),
                    );
                  },
                ),
                // Child node
                _buildNode(
                  name: widget.childName ?? 'Pending',
                  avatar: widget.childAvatar ?? '❓',
                  position: widget.childPosition,
                  isActive: widget.childName != null,
                  onTap: widget.onChildTap,
                  label: 'INVITED',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    return ChainCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactNode(
            avatar: widget.parentAvatar ?? '🌟',
            position: widget.parentPosition ?? 0,
            isActive: widget.parentName != null,
          ),
          Icon(
            Icons.link,
            color: Colors.white.withOpacity(0.3),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildCompactNode(
                  avatar: widget.userAvatar,
                  position: widget.userPosition,
                  isActive: true,
                  isUser: true,
                ),
              );
            },
          ),
          Icon(
            Icons.link,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildCompactNode(
            avatar: widget.childAvatar ?? '❓',
            position: widget.childPosition,
            isActive: widget.childName != null,
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required String name,
    required String avatar,
    int? position,
    required bool isActive,
    bool isUser = false,
    VoidCallback? onTap,
    required String label,
  }) {
    final node = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: isUser
              ? const Color(0xFF00D4FF)
              : Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: isUser ? 80 : 60,
          height: isUser ? 80 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
              ? LinearGradient(
                  colors: isUser
                    ? [const Color(0xFF7C3AED), const Color(0xFF00D4FF)]
                    : [
                        const Color(0xFF7C3AED).withOpacity(0.5),
                        const Color(0xFF00D4FF).withOpacity(0.5),
                      ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            color: !isActive ? Colors.white.withOpacity(0.1) : null,
            border: Border.all(
              color: isUser
                ? const Color(0xFF00D4FF)
                : Colors.white.withOpacity(0.3),
              width: isUser ? 3 : 1,
            ),
            boxShadow: isUser
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          ),
          child: Center(
            child: Text(
              avatar,
              style: TextStyle(fontSize: isUser ? 32 : 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: isUser ? 14 : 12,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white.withOpacity(isActive ? 1.0 : 0.5),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (position != null)
          Text(
            '#$position',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF00D4FF).withOpacity(0.7),
            ),
          ),
      ],
    );

    if (onTap != null && isActive) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: node,
      );
    }

    return node;
  }

  Widget _buildCompactNode({
    required String avatar,
    int? position,
    required bool isActive,
    bool isUser = false,
  }) {
    return Container(
      width: isUser ? 50 : 40,
      height: isUser ? 50 : 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
          ? LinearGradient(
              colors: isUser
                ? [const Color(0xFF7C3AED), const Color(0xFF00D4FF)]
                : [
                    const Color(0xFF7C3AED).withOpacity(0.5),
                    const Color(0xFF00D4FF).withOpacity(0.5),
                  ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
        color: !isActive ? Colors.white.withOpacity(0.1) : null,
        border: Border.all(
          color: isUser
            ? const Color(0xFF00D4FF)
            : Colors.white.withOpacity(0.3),
          width: isUser ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          avatar,
          style: TextStyle(fontSize: isUser ? 20 : 16),
        ),
      ),
    );
  }
}

/// Custom painter for the connection lines between nodes
class ChainConnectionPainter extends CustomPainter {
  final double progress;
  final bool hasParent;
  final bool hasChild;

  ChainConnectionPainter({
    required this.progress,
    required this.hasParent,
    required this.hasChild,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C3AED).withOpacity(0.3 * progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.5 * progress),
          const Color(0xFF7C3AED).withOpacity(0.5 * progress),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final topY = size.height * 0.2;
    final centerY = size.height * 0.5;
    final bottomY = size.height * 0.8;

    if (hasParent) {
      final path = Path()
        ..moveTo(centerX, topY)
        ..lineTo(centerX, centerY - 40);

      canvas.drawPath(path, gradientPaint);

      // Draw animated dots
      for (int i = 0; i < 3; i++) {
        final dotY = topY + (centerY - topY - 40) * (progress + i * 0.3) % 1;
        canvas.drawCircle(
          Offset(centerX, dotY),
          2,
          Paint()..color = const Color(0xFF00D4FF).withOpacity(0.5),
        );
      }
    }

    if (hasChild) {
      final path = Path()
        ..moveTo(centerX, centerY + 40)
        ..lineTo(centerX, bottomY);

      canvas.drawPath(path, gradientPaint);

      // Draw animated dots
      for (int i = 0; i < 3; i++) {
        final dotY = centerY + 40 + (bottomY - centerY - 40) * (progress + i * 0.3) % 1;
        canvas.drawCircle(
          Offset(centerX, dotY),
          2,
          Paint()..color = const Color(0xFF7C3AED).withOpacity(0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ChainConnectionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}