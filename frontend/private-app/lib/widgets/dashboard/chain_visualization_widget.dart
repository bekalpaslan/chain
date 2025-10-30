import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Chain visualization widget that displays chain members vertically
/// Shows 5 members for admin users, 3 for regular users
class ChainVisualizationWidget extends StatefulWidget {
  final List<ChainMember> chainMembers;

  const ChainVisualizationWidget({
    super.key,
    required this.chainMembers,
  });

  @override
  State<ChainVisualizationWidget> createState() => _ChainVisualizationWidgetState();
}

class _ChainVisualizationWidgetState extends State<ChainVisualizationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;
  late Animation<double> _flowAnimation;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _flowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flowController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.shadowDark,
            theme.shadowDark.withOpacity(0.8),
          ],
        ),
        // No borderRadius - extends to edges
        border: Border(
          top: BorderSide(
            color: theme.gray700.withOpacity(0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: theme.gray700.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          // Outer shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        // Inner container for 3D effect
        decoration: BoxDecoration(
          // No borderRadius
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2), // Darker at top for inner shadow
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.1), // Slightly darker at bottom
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Add horizontal padding for content
        child: Column(
        children: [
          // Title with version
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'THE CHAIN',
                style: TextStyle(
                  color: theme.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.mysticViolet.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.mysticViolet.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'v1.1.0',
                  style: TextStyle(
                    color: theme.mysticViolet,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chain members display - vertical
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildChainDisplay(),
              ),
            ),
          ),

        ],
      ),
      ),
    );
  }

  List<Widget> _buildChainDisplay() {
    final widgets = <Widget>[];

    for (int i = 0; i < widget.chainMembers.length; i++) {
      final member = widget.chainMembers[i];
      final isLast = i == widget.chainMembers.length - 1;

      // Build node with integrated connector
      widgets.add(_buildMemberNodeWithConnector(member, !isLast));
    }

    return widgets;
  }

  Widget _buildMemberNodeWithConnector(ChainMember member, bool hasConnectorBelow) {
    return Stack(
      children: [
        // Connector line positioned behind and below the circle
        if (hasConnectorBelow)
          Positioned(
            left: 32, // Position to align with circle center
            top: member.isCurrentUser ? 64 : 56, // Start at bottom of circle
            child: _buildAnimatedConnector(),
          ),

        // The member node on top
        _buildMemberNode(member),
      ],
    );
  }

  Widget _buildMemberNode(ChainMember member) {
    final theme = AppTheme.darkMystique;

    // Determine node color based on status
    Color nodeColor;
    Color borderColor;
    double opacity = 1.0;

    switch (member.status) {
      case ChainMemberStatus.genesis:
        nodeColor = theme.gold;
        borderColor = theme.gold;
        break;
      case ChainMemberStatus.tip:
        nodeColor = const Color(0xFF00D4FF); // Cyan color for tip
        borderColor = const Color(0xFF00D4FF);
        break;
      case ChainMemberStatus.active:
        nodeColor = theme.emerald;
        borderColor = theme.emerald;
        opacity = member.isCurrentUser ? 1.0 : 0.7;
        break;
      case ChainMemberStatus.removed:
      case ChainMemberStatus.expired:
        nodeColor = theme.errorRed;
        borderColor = theme.errorRed;
        opacity = 0.5;
        break;
      default:
        nodeColor = theme.mysticViolet;
        borderColor = theme.mysticViolet;
        opacity = 0.7;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Node circle
          Container(
            width: member.isCurrentUser ? 64 : 56,
            height: member.isCurrentUser ? 64 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  nodeColor.withOpacity(opacity * 0.3), // Lighter in center
                  nodeColor.withOpacity(opacity * 0.2), // Base color
                  nodeColor.withOpacity(opacity * 0.1), // Darker at edges
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: borderColor.withOpacity(opacity),
                width: member.isCurrentUser ? 3 : 2,
              ),
              boxShadow: [
                // Outer shadow for depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
                // Glow for current user
                if (member.isCurrentUser)
                  BoxShadow(
                    color: borderColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Container(
              // Inner container for 3D effect
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1), // Light reflection
                    Colors.transparent,
                    Colors.black.withOpacity(0.2), // Shadow
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Position number
                  Text(
                    '#${member.position}',
                    style: TextStyle(
                      color: borderColor,
                      fontSize: member.isCurrentUser ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Initials or name
                  Text(
                    _getDisplayText(member),
                    style: TextStyle(
                      color: borderColor.withOpacity(0.9),
                      fontSize: member.isCurrentUser ? 12 : 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(width: 16),

          // Member info card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: member.isCurrentUser
                    ? borderColor.withOpacity(0.1)
                    : theme.shadowDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: member.isCurrentUser
                      ? borderColor.withOpacity(0.3)
                      : theme.gray700.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                // Inner container for 3D effect
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15), // Darker at top
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.08), // Slightly darker at bottom
                    ],
                    stops: const [0.0, 0.08, 0.92, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display name
                  Text(
                    member.displayName,
                    style: TextStyle(
                      color: member.isCurrentUser ? borderColor : Colors.white,
                      fontSize: 14,
                      fontWeight: member.isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Chain key and status
                  Row(
                    children: [
                      Text(
                        member.chainKey,
                        style: TextStyle(
                          color: theme.gray500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: borderColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          member.status.label.toUpperCase(),
                          style: TextStyle(
                            color: borderColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText(ChainMember member) {
    // If display name is censored (ends with ***), show initials
    if (member.displayName.endsWith('***')) {
      return member.displayName.substring(0, 2);
    }

    // For full names, show initials
    final parts = member.displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    // Fallback to first 2 letters
    return member.displayName.substring(0, 2).toUpperCase();
  }

  Widget _buildConnector() {
    final theme = AppTheme.darkMystique;

    return SizedBox(
      width: double.infinity,
      height: 24,
      child: Center(
        child: Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.gray700.withOpacity(0.5),
                theme.gray700.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedConnector() {
    final theme = AppTheme.darkMystique;

    return AnimatedBuilder(
      animation: _flowAnimation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: 32, // Height to connect between circles
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.gray700.withOpacity(0.1),
                    theme.gold.withOpacity(0.3 + 0.3 * _flowAnimation.value),
                    theme.gold.withOpacity(0.5 + 0.4 * _flowAnimation.value),
                    theme.gold.withOpacity(0.3 + 0.3 * (1 - _flowAnimation.value)),
                    theme.gray700.withOpacity(0.1),
                  ],
                  stops: [
                    0.0,
                    _flowAnimation.value * 0.4,
                    _flowAnimation.value * 0.5,
                    _flowAnimation.value * 0.6,
                    1.0,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.gold.withOpacity(0.2 * _flowAnimation.value),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
        );
      },
    );
  }
}