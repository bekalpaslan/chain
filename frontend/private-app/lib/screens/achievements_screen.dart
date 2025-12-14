import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import '../providers/dashboard_providers.dart';
import '../models/dashboard_models.dart';

/// Achievements screen displaying all badges and progress
/// Uses Dark Mystique theme with rarity-based colors
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load dashboard data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardDataProvider.notifier).loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: DarkMystiqueTheme.shadowPurple.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DarkMystiqueTheme.etherealPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DarkMystiqueTheme.mysticViolet,
          labelColor: DarkMystiqueTheme.etherealPurple,
          unselectedLabelColor: DarkMystiqueTheme.textMuted,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Earned'),
            Tab(text: 'In Progress'),
          ],
        ),
      ),
      body: dashboardState.when(
        loading: () => const Center(
          child: MystiqueLoadingIndicator(message: 'Loading achievements...'),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: DarkMystiqueTheme.errorPulse, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load achievements',
                style: TextStyle(color: DarkMystiqueTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              MystiqueButton(
                text: 'Retry',
                onPressed: () => ref.read(dashboardDataProvider.notifier).loadDashboardData(),
                variant: MystiqueButtonVariant.secondary,
              ),
            ],
          ),
        ),
        data: (data) => _buildAchievementsTabs(data.achievements),
      ),
    );
  }

  Widget _buildAchievementsTabs(List<Achievement> achievements) {
    final earned = achievements.where((a) => a.isEarned).toList();
    final inProgress = achievements.where((a) => a.isInProgress && !a.isEarned).toList();

    return TabBarView(
      controller: _tabController,
      children: [
        // All achievements
        _buildAchievementsList(achievements, showAll: true),
        // Earned only
        _buildAchievementsList(earned, emptyMessage: 'No achievements earned yet'),
        // In progress only
        _buildAchievementsList(inProgress, emptyMessage: 'No achievements in progress'),
      ],
    );
  }

  Widget _buildAchievementsList(
    List<Achievement> achievements, {
    String emptyMessage = 'No achievements found',
    bool showAll = false,
  }) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: DarkMystiqueTheme.textMuted,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: DarkMystiqueTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Group by rarity if showing all
    if (showAll) {
      final grouped = <AchievementRarity, List<Achievement>>{};
      for (final rarity in AchievementRarity.values.reversed) {
        final rarityAchievements = achievements.where((a) => a.rarity == rarity).toList();
        if (rarityAchievements.isNotEmpty) {
          grouped[rarity] = rarityAchievements;
        }
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final rarity = grouped.keys.elementAt(index);
          final items = grouped[rarity]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 24),
              _buildRarityHeader(rarity, items.length),
              const SizedBox(height: 12),
              ...items.map((a) => _buildAchievementCard(a)),
            ],
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildRarityHeader(AchievementRarity rarity, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: rarity.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: rarity.color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          rarity.label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: rarity.color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: rarity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: rarity.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isEarned = achievement.isEarned;
    final rarityColor = achievement.rarity.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rarityColor.withOpacity(isEarned ? 0.15 : 0.05),
            DarkMystiqueTheme.shadowPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rarityColor.withOpacity(isEarned ? 0.5 : 0.2),
          width: isEarned ? 2 : 1,
        ),
        boxShadow: isEarned
            ? [
                BoxShadow(
                  color: rarityColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAchievementDetails(achievement),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon/Emoji container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rarityColor.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: isEarned
                        ? Text(
                            achievement.icon,
                            style: const TextStyle(fontSize: 28),
                          )
                        : Icon(
                            Icons.lock_outline,
                            color: DarkMystiqueTheme.textMuted,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isEarned
                                    ? DarkMystiqueTheme.textPrimary
                                    : DarkMystiqueTheme.textSecondary,
                              ),
                            ),
                          ),
                          if (isEarned)
                            Icon(
                              Icons.check_circle,
                              color: DarkMystiqueTheme.successGlow,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isEarned
                              ? DarkMystiqueTheme.textSecondary
                              : DarkMystiqueTheme.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isEarned && achievement.progress > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: achievement.progress,
                                  backgroundColor: DarkMystiqueTheme.twilightGray,
                                  valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              achievement.progressPercentage,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: rarityColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isEarned && achievement.earnedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Earned ${_formatDate(achievement.earnedAt!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: DarkMystiqueTheme.textMuted,
                          ),
                        ),
                      ],
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

  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAchievementDetailsSheet(achievement),
    );
  }

  Widget _buildAchievementDetailsSheet(Achievement achievement) {
    final rarityColor = achievement.rarity.color;
    final isEarned = achievement.isEarned;

    return Container(
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: rarityColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icon with glow
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        rarityColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: rarityColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    achievement.rarity.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: rarityColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  achievement.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: DarkMystiqueTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DarkMystiqueTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Status
                if (isEarned) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DarkMystiqueTheme.successGlow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DarkMystiqueTheme.successGlow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: DarkMystiqueTheme.successGlow,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Achievement Unlocked!',
                              style: TextStyle(
                                color: DarkMystiqueTheme.successGlow,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (achievement.earnedAt != null)
                              Text(
                                _formatDate(achievement.earnedAt!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: DarkMystiqueTheme.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Progress
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: DarkMystiqueTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${achievement.currentCount ?? 0} / ${achievement.targetCount ?? '?'}',
                            style: TextStyle(
                              color: rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor: DarkMystiqueTheme.twilightGray,
                          valueColor: AlwaysStoppedAnimation<Color>(rarityColor),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
