import 'package:flutter/material.dart';
import 'package:thechain_shared/widgets/chain_components.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Enhanced stats section using shared components
/// Replaces the traditional stats grid with animated cards
class EnhancedStatsSection extends StatelessWidget {
  final DashboardStats stats;
  final Function(String) onStatTap;

  const EnhancedStatsSection({
    super.key,
    required this.stats,
    required this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600
      ? (screenWidth - 48) / 2
      : (screenWidth - 64) / 3;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with glassmorphic effect
          ChainCard(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            borderRadius: 12,
            backgroundColor: theme.mysticViolet,
            child: Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'CHAIN METRICS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid with animated cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              AnimatedStatCard(
                title: 'Chain Length',
                value: stats.chainLength,
                icon: Icons.link,
                primaryColor: theme.mysticViolet,
                secondaryColor: theme.ghostCyan,
                suffix: ' users',
                width: cardWidth,
                showTrend: true,
                trendValue: stats.growthRate,
              ),
              AnimatedStatCard(
                title: 'Active Invitations',
                value: stats.activeInvitations,
                icon: Icons.confirmation_number,
                primaryColor: theme.emerald,
                secondaryColor: theme.ghostCyan,
                width: cardWidth,
              ),
              AnimatedStatCard(
                title: 'Your Descendants',
                value: stats.descendantsCount,
                icon: Icons.account_tree,
                primaryColor: theme.ghostCyan,
                secondaryColor: theme.mysticViolet,
                suffix: stats.descendantsCount > 1000 ? 'k' : '',
                width: cardWidth,
              ),
              AnimatedStatCard(
                title: 'Days in Chain',
                value: stats.daysInChain,
                icon: Icons.calendar_today,
                primaryColor: theme.amber,
                secondaryColor: theme.emerald,
                suffix: ' days',
                width: cardWidth,
              ),
              AnimatedStatCard(
                title: 'Success Rate',
                value: stats.successRate.toInt(),
                icon: Icons.trending_up,
                primaryColor: theme.emerald,
                secondaryColor: theme.ghostCyan,
                suffix: '%',
                width: cardWidth,
                showTrend: true,
                trendValue: 5.2,
              ),
              AnimatedStatCard(
                title: 'Global Rank',
                value: stats.globalRank ?? 0,
                icon: Icons.emoji_events,
                primaryColor: theme.gold,
                secondaryColor: theme.amber,
                prefix: '#',
                width: cardWidth,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick insights
          ChainCard(
            padding: const EdgeInsets.all(16),
            borderColor: theme.ghostCyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph,
                      color: theme.ghostCyan,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildInsights(stats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInsights(DashboardStats stats) {
    final insights = <Widget>[];

    // Growth insight
    if (stats.growthRate > 10) {
      insights.add(_buildInsightRow(
        icon: Icons.rocket_launch,
        text: 'Chain is growing rapidly! +${stats.growthRate.toStringAsFixed(1)}% this week',
        color: const Color(0xFF10B981),
      ));
    }

    // Success rate insight
    if (stats.successRate > 80) {
      insights.add(_buildInsightRow(
        icon: Icons.star,
        text: 'Excellent invitation success rate: ${stats.successRate.toStringAsFixed(0)}%',
        color: const Color(0xFFF59E0B),
      ));
    }

    // Descendants insight
    if (stats.descendantsCount > 100) {
      insights.add(_buildInsightRow(
        icon: Icons.group,
        text: 'Your network has reached ${stats.descendantsCount} members!',
        color: const Color(0xFF00D4FF),
      ));
    }

    // Days milestone
    if (stats.daysInChain % 30 == 0 && stats.daysInChain > 0) {
      insights.add(_buildInsightRow(
        icon: Icons.celebration,
        text: 'Milestone: ${stats.daysInChain} days in the chain!',
        color: const Color(0xFF7C3AED),
      ));
    }

    if (insights.isEmpty) {
      insights.add(_buildInsightRow(
        icon: Icons.info_outline,
        text: 'Keep growing your chain to unlock insights',
        color: Colors.white.withOpacity(0.5),
      ));
    }

    return insights;
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats model extension for demo purposes
extension DashboardStatsEnhanced on DashboardStats {
  int get chainLength => totalMembers;
  int get activeInvitations => activeTickets;
  int get descendantsCount => 156; // Mock value
  int get daysInChain => DateTime.now().difference(joinedAt).inDays;
  double get growthRate => 12.5; // Mock value
  double get successRate => 85.0; // Mock value
  int? get globalRank => 1247; // Mock value
}