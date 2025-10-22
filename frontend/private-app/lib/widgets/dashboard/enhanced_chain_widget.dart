import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For PointerDeviceKind
import 'package:thechain_shared/widgets/chain_components.dart';
import 'package:thechain_shared/widgets/chain_components/country_flag_widget.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Custom scroll behavior that enables mouse dragging
class MouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// Enhanced chain visualization with country flags
/// Shows chain members with their country flags as subtle background elements
class EnhancedChainWidget extends StatefulWidget {
  final List<ChainMember> members;
  final ScrollController? scrollController;

  const EnhancedChainWidget({
    super.key,
    required this.members,
    this.scrollController,
  });

  @override
  State<EnhancedChainWidget> createState() => _EnhancedChainWidgetState();
}

class _EnhancedChainWidgetState extends State<EnhancedChainWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimations = List.generate(
      widget.members.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return ChainCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.mysticViolet, theme.ghostCyan],
                ).createShader(bounds),
                child: const Icon(
                  Icons.link,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CHAIN MEMBERS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.mysticViolet, theme.ghostCyan],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.members.length} MEMBERS',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chain visualization with mouse and touch support
          Expanded(
            child: ScrollConfiguration(
              behavior: MouseDragScrollBehavior(), // Use our custom scroll behavior
              child: Scrollbar(
                controller: widget.scrollController,
                thumbVisibility: true, // Always show scrollbar
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.builder(
                  controller: widget.scrollController,
                  physics: const ClampingScrollPhysics(), // Better for mouse wheel
                  itemCount: widget.members.length,
                  itemBuilder: (context, index) {
                final member = widget.members[index];
                final isFirst = index == 0;
                final isLast = index == widget.members.length - 1;

                return AnimatedBuilder(
                  animation: _fadeAnimations[index],
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimations[index],
                      child: Column(
                        children: [
                          // Connection line (except for first member)
                          if (!isFirst) _buildConnectionLine(theme),

                          // Member node
                          _buildMemberNode(member, theme),

                          // Bottom connection (except for last member)
                          if (!isLast) const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    ],
      ),
    );
  }

  Widget _buildConnectionLine(DarkMystiqueTheme theme) {
    return Container(
      width: 2,
      height: 30,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.ghostCyan.withOpacity(0.3),
            theme.mysticViolet.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberNode(ChainMember member, DarkMystiqueTheme theme) {
    final isCurrentUser = member.isCurrentUser;
    final borderColor = _getStatusColor(member.status, theme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isCurrentUser
                    ? theme.mysticViolet.withOpacity(0.1)
                    : theme.shadowDark.withOpacity(0.5),
                  isCurrentUser
                    ? theme.ghostCyan.withOpacity(0.05)
                    : theme.shadowDark.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentUser
                  ? borderColor.withOpacity(0.5)
                  : borderColor.withOpacity(0.2),
                width: isCurrentUser ? 2 : 1,
              ),
              boxShadow: [
                if (isCurrentUser)
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Country flag background (positioned absolute)
                if (member.countryCode != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: CountryFlagWidget(
                      countryCode: member.countryCode,
                      size: 32,
                      opacity: 0.15,
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Position indicator
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              borderColor.withOpacity(0.3),
                              borderColor.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: borderColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${member.position}',
                                style: TextStyle(
                                  color: borderColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (member.avatarEmoji != null)
                                Text(
                                  member.avatarEmoji!,
                                  style: const TextStyle(fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Member info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.displayName,
                                    style: TextStyle(
                                      color: isCurrentUser
                                        ? theme.ghostCyan
                                        : Colors.white,
                                      fontSize: 14,
                                      fontWeight: isCurrentUser
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentUser)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme.mysticViolet, theme.ghostCyan],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'YOU',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Chain key
                                Expanded(
                                  child: Text(
                                    member.chainKey,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Country indicator (if available)
                                if (member.countryCode != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 10,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          member.countryCode!.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Status badge
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: borderColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: borderColor.withOpacity(0.3),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ChainMemberStatus status, DarkMystiqueTheme theme) {
    switch (status) {
      case ChainMemberStatus.active:
        return theme.emerald;
      case ChainMemberStatus.pending:
        return theme.amber;
      case ChainMemberStatus.expired:
        return theme.errorRed;
      case ChainMemberStatus.removed:
        return theme.gray500;
      case ChainMemberStatus.tip:
        return theme.ghostCyan;
      case ChainMemberStatus.genesis:
        return theme.gold;
      case ChainMemberStatus.milestone:
        return theme.mysticViolet;
      case ChainMemberStatus.ghost:
        return theme.gray500.withOpacity(0.5);
    }
  }
}