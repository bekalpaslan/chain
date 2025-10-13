import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

/// Critical actions area widget
/// Displays urgent actions that require user attention
class CriticalActionsArea extends StatefulWidget {
  final List<CriticalAction> actions;

  const CriticalActionsArea({
    super.key,
    required this.actions,
  });

  @override
  State<CriticalActionsArea> createState() => _CriticalActionsAreaState();
}

class _CriticalActionsAreaState extends State<CriticalActionsArea>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final Map<String, AnimationController> _dismissControllers = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    for (final controller in _dismissControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _dismissAction(String actionId) {
    if (!_dismissControllers.containsKey(actionId)) {
      _dismissControllers[actionId] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }

    _dismissControllers[actionId]!.forward().then((_) {
      // In a real app, you'd update the state to remove the action
      HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.errorRed.withOpacity(
                        0.2 + (math.sin(_pulseController.value * math.pi * 2) * 0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.priority_high,
                      color: theme.errorRed,
                      size: 16,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Requires Attention',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.actions.length} ${widget.actions.length == 1 ? 'action' : 'actions'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Action cards
          ...widget.actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            final delay = index * 100;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + delay),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildActionCard(action),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionCard(CriticalAction action) {
    final theme = AppTheme.darkMystique;
    final color = _getActionColor(action.type);
    final icon = _getActionIcon(action.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            action.action?.call();
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon with pulse animation
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (math.sin(_pulseController.value * math.pi * 2) * 0.1);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            action.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            action.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action button
                    Icon(
                      Icons.arrow_forward_ios,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
                // Countdown timer (if applicable)
                if (action.timeRemaining != null) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  _buildCountdownTimer(action.timeRemaining!, color),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(Duration timeRemaining, Color color) {
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;
    final seconds = timeRemaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HRS'),
          _buildTimeSeparator(),
          _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'MIN'),
          _buildTimeSeparator(),
          _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'SEC'),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getActionColor(CriticalActionType type) {
    final theme = AppTheme.darkMystique;
    switch (type) {
      case CriticalActionType.ticketExpiring:
      case CriticalActionType.ticketExpired:
        return theme.amber;
      case CriticalActionType.becameTip:
        return theme.ghostCyan;
      case CriticalActionType.chainBroken:
      case CriticalActionType.inviteRejected:
        return theme.errorRed;
      case CriticalActionType.inviteAccepted:
        return theme.emerald;
      case CriticalActionType.achievementUnlocked:
        return theme.gold;
    }
  }

  IconData _getActionIcon(CriticalActionType type) {
    switch (type) {
      case CriticalActionType.ticketExpiring:
        return Icons.timer;
      case CriticalActionType.ticketExpired:
        return Icons.timer_off;
      case CriticalActionType.becameTip:
        return Icons.star;
      case CriticalActionType.chainBroken:
        return Icons.link_off;
      case CriticalActionType.inviteAccepted:
        return Icons.check_circle;
      case CriticalActionType.inviteRejected:
        return Icons.cancel;
      case CriticalActionType.achievementUnlocked:
        return Icons.emoji_events;
    }
  }
}