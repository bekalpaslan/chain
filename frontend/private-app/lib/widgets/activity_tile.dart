import 'package:flutter/material.dart';

/// Activity types for the activity feed
enum ActivityType {
  memberJoined,
  invitationExpired,
  chainGrowth,
  milestone,
  invitationSent,
  becameTip,
}

/// A single activity item in the feed
class Activity {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
  });
}

/// Activity tile widget for displaying chain events
class ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;

  const ActivityTile({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activityInfo = _getActivityInfo(activity.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1F2937).withValues(alpha: 0.4),
              const Color(0xFF111827).withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activityInfo.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activityInfo.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activityInfo.color.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                activityInfo.icon,
                color: activityInfo.color,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Timestamp
                  Text(
                    _formatTimeAgo(activity.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: activityInfo.color.withValues(alpha: 0.7),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Format timestamp as relative time (e.g., "2 hours ago")
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Get icon and color for activity type
  ActivityInfo _getActivityInfo(ActivityType type) {
    switch (type) {
      case ActivityType.memberJoined:
        return ActivityInfo(
          icon: Icons.person_add_rounded,
          color: const Color(0xFF10B981), // Green
        );
      case ActivityType.invitationExpired:
        return ActivityInfo(
          icon: Icons.timer_off_rounded,
          color: const Color(0xFFEF4444), // Red
        );
      case ActivityType.chainGrowth:
        return ActivityInfo(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF3B82F6), // Blue
        );
      case ActivityType.milestone:
        return ActivityInfo(
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFFFD700), // Gold
        );
      case ActivityType.invitationSent:
        return ActivityInfo(
          icon: Icons.send_rounded,
          color: const Color(0xFF7C3AED), // Violet
        );
      case ActivityType.becameTip:
        return ActivityInfo(
          icon: Icons.flash_on_rounded,
          color: const Color(0xFF10B981), // Green
        );
    }
  }
}

/// Activity icon and color information
class ActivityInfo {
  final IconData icon;
  final Color color;

  ActivityInfo({
    required this.icon,
    required this.color,
  });
}

/// Activity feed section with header
class ActivityFeed extends StatelessWidget {
  final List<Activity> activities;
  final VoidCallback? onViewAll;

  const ActivityFeed({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.95),
                letterSpacing: 0.5,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Activity list
        if (activities.isEmpty)
          _buildEmptyState()
        else
          ...activities.map((activity) => ActivityTile(activity: activity)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F2937).withValues(alpha: 0.3),
            const Color(0xFF111827).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your chain activity will appear here',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
