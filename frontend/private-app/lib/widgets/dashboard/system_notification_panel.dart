import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// System notification panel for displaying admin messages
class SystemNotificationPanel extends StatefulWidget {
  final List<SystemNotification> notifications;
  final VoidCallback? onDismiss;

  const SystemNotificationPanel({
    super.key,
    required this.notifications,
    this.onDismiss,
  });

  @override
  State<SystemNotificationPanel> createState() => _SystemNotificationPanelState();
}

class _SystemNotificationPanelState extends State<SystemNotificationPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    if (widget.notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.shadowDark,
            theme.shadowDark.withOpacity(0.9),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.gold.withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        // Inner container for 3D effect
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
            stops: const [0.0, 0.05, 0.95, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Header with expand/collapse button
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    // Alert icon with glow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.gold.withOpacity(0.1),
                        border: Border.all(
                          color: theme.gold.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.gold.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: theme.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title
                    Text(
                      'SYSTEM NOTIFICATIONS',
                      style: TextStyle(
                        color: theme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),

                    // Badge with count
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.errorRed.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.errorRed.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Expand/collapse icon
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.gray500,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            // Notifications list
            if (_isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: widget.notifications.length > 3 ? 200 : double.infinity,
                  ),
                  child: ListView.builder(
                    shrinkWrap: widget.notifications.length <= 3,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: widget.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = widget.notifications[index];
                      return _buildNotificationItem(notification, theme);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(SystemNotification notification, theme) {
    Color priorityColor;
    IconData priorityIcon;

    switch (notification.priority) {
      case NotificationPriority.critical:
        priorityColor = theme.errorRed;
        priorityIcon = Icons.error;
        break;
      case NotificationPriority.high:
        priorityColor = theme.gold;
        priorityIcon = Icons.warning;
        break;
      case NotificationPriority.medium:
        priorityColor = theme.mysticViolet;
        priorityIcon = Icons.info;
        break;
      case NotificationPriority.low:
        priorityColor = theme.gray500;
        priorityIcon = Icons.notifications;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        // Inner container for 3D effect
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.05),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: priorityColor.withOpacity(0.1),
                border: Border.all(
                  color: priorityColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                priorityIcon,
                color: priorityColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge and time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: priorityColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notification.type.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(
                          color: theme.gray600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Message
                  if (notification.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message!,
                      style: TextStyle(
                        color: theme.gray400,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Notification model classes
class SystemNotification {
  final String id;
  final String title;
  final String? message;
  final String type;
  final NotificationPriority priority;
  final DateTime timestamp;

  const SystemNotification({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
  });
}

enum NotificationPriority {
  critical,
  high,
  medium,
  low,
}