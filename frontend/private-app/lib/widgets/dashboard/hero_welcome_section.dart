import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thechain_shared/models/user.dart';
import '../../theme/app_theme.dart';

/// Hero welcome section for the dashboard
/// Displays personalized greeting, chain key, and status
class HeroWelcomeSection extends StatefulWidget {
  final User user;
  final DateTime lastActivity;

  const HeroWelcomeSection({
    super.key,
    required this.user,
    required this.lastActivity,
  });

  @override
  State<HeroWelcomeSection> createState() => _HeroWelcomeSectionState();
}

class _HeroWelcomeSectionState extends State<HeroWelcomeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getLastActivityText() {
    final difference = DateTime.now().difference(widget.lastActivity);
    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inHours < 1) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingXL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.shadowDark,
            theme.deepVoid,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                theme.mysticViolet,
                                theme.ghostCyan,
                                Colors.white,
                              ],
                              stops: [
                                0.0,
                                0.4 + _shimmerAnimation.value * 0.1,
                                0.6 + _shimmerAnimation.value * 0.1,
                                1.0,
                              ],
                              transform: GradientRotation(_shimmerAnimation.value),
                            ).createShader(bounds);
                          },
                          child: Text(
                            widget.user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Status indicator
              _buildStatusIndicator(),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Chain key and position row
          Row(
            children: [
              _buildChainKeyCard(),
              const SizedBox(width: AppTheme.spacingM),
              _buildPositionCard(),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Activity status
          _buildActivityStatus(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final theme = AppTheme.darkMystique;
    final isActive = DateTime.now().difference(widget.lastActivity).inMinutes < 5;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color: isActive ? theme.emerald : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? theme.emerald : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Online' : 'Away',
            style: TextStyle(
              color: isActive ? theme.emerald : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainKeyCard() {
    final theme = AppTheme.darkMystique;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Copy chain key to clipboard
          Clipboard.setData(ClipboardData(text: widget.user.chainKey));
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Chain key copied!'),
              backgroundColor: theme.emerald,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.mysticViolet.withOpacity(0.1),
                theme.mysticViolet.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: theme.mysticViolet.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.link,
                color: theme.mysticViolet,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chain Key',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.user.chainKey,
                      style: TextStyle(
                        color: theme.mysticViolet,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy_outlined,
                color: theme.mysticViolet.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionCard() {
    final theme = AppTheme.darkMystique;
    final isTopUser = widget.user.position <= 100;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTopUser
              ? [theme.gold.withOpacity(0.2), theme.gold.withOpacity(0.1)]
              : [theme.ghostCyan.withOpacity(0.1), theme.ghostCyan.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isTopUser ? theme.gold.withOpacity(0.5) : theme.ghostCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTopUser ? Icons.emoji_events : Icons.timeline,
                color: isTopUser ? theme.gold : theme.ghostCyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '#${widget.user.position}',
                style: TextStyle(
                  color: isTopUser ? theme.gold : theme.ghostCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isTopUser)
            Text(
              'Top 100',
              style: TextStyle(
                color: theme.gold.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityStatus() {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white.withOpacity(0.5),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            _getLastActivityText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Streak indicator (if applicable)
          if (widget.user.position > 0) ...[
            Icon(
              Icons.local_fire_department,
              color: theme.amber,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              '7 day streak',
              style: TextStyle(
                color: theme.amber,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}