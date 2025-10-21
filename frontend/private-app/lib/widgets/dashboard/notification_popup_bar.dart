import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'system_notification_panel.dart';

/// Notification bar that shows at the top and expands to show last 3 notifications
class NotificationPopupBar extends StatefulWidget {
  final List<SystemNotification> notifications;
  final VoidCallback? onDismiss;

  const NotificationPopupBar({
    super.key,
    required this.notifications,
    this.onDismiss,
  });

  @override
  State<NotificationPopupBar> createState() => _NotificationPopupBarState();
}

class _NotificationPopupBarState extends State<NotificationPopupBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    if (widget.notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get last 3 notifications
    final displayNotifications = widget.notifications.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.shadowDark,
            theme.shadowDark.withOpacity(0.95),
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
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clickable header bar
          InkWell(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Animated alert icon with pulse effect
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Container(
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
                              color: theme.gold.withOpacity(0.3 * (1 - value)),
                              blurRadius: 20 * value,
                              spreadRadius: 2 * value,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: theme.gold,
                          size: 20,
                        ),
                      );
                    },
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
                      '${displayNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Latest notification preview (when collapsed)
                  if (!_isExpanded && displayNotifications.isNotEmpty)
                    Expanded(
                      child: Text(
                        displayNotifications.first.title,
                        style: TextStyle(
                          color: theme.gray400,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.gray500,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded notification list
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.gold.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: displayNotifications.map((notification) {
                  return _buildNotificationItem(notification, theme);
                }).toList(),
              ),
            ),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withOpacity(0.2),
          width: 1,
        ),
      ),
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