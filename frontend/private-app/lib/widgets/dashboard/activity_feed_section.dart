import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Activity feed section widget
/// TODO: Implement full activity feed with filters
class ActivityFeedSection extends StatelessWidget {
  final List<Activity> activities;
  final VoidCallback onLoadMore;

  const ActivityFeedSection({
    super.key,
    required this.activities,
    required this.onLoadMore,
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
                Icons.timeline,
                color: theme.mysticViolet,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...activities.map((activity) => _buildActivityTile(activity, theme)),
          if (activities.length >= 5)
            Center(
              child: TextButton(
                onPressed: onLoadMore,
                child: Text(
                  'Load More',
                  style: TextStyle(color: theme.mysticViolet),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Activity activity, DarkMystiqueTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.type.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.type.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity.type.icon,
              color: activity.type.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.timeAgo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}