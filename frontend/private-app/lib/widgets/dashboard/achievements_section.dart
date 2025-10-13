import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Achievements section widget
/// TODO: Implement full achievements with progress tracking
class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;
  final Map<String, double> progress;

  const AchievementsSection({
    super.key,
    required this.achievements,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.gold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementCard(achievement, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, DarkMystiqueTheme theme) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.rarity.color.withOpacity(0.2),
            achievement.rarity.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!achievement.isEarned) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: achievement.progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(achievement.rarity.color),
              minHeight: 2,
            ),
          ],
        ],
      ),
    );
  }
}