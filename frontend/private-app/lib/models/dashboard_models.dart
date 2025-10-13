import 'package:flutter/material.dart';
import 'package:thechain_shared/models/user.dart';

/// Main dashboard data container
class DashboardData {
  final User user;
  final List<ChainMember> chainMembers;
  final DashboardStats stats;
  final List<CriticalAction> criticalActions;
  final List<Activity> recentActivities;
  final List<Achievement> achievements;
  final Map<String, double> achievementProgress;
  final int unreadNotifications;
  final bool hasActiveTicket;
  final DateTime lastActivity;

  DashboardData({
    required this.user,
    required this.chainMembers,
    required this.stats,
    required this.criticalActions,
    required this.recentActivities,
    required this.achievements,
    required this.achievementProgress,
    required this.unreadNotifications,
    required this.hasActiveTicket,
    required this.lastActivity,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: User.fromJson(json['user']),
      chainMembers: (json['chainMembers'] as List)
          .map((item) => ChainMember.fromJson(item))
          .toList(),
      stats: DashboardStats.fromJson(json['stats']),
      criticalActions: (json['criticalActions'] as List)
          .map((item) => CriticalAction.fromJson(item))
          .toList(),
      recentActivities: (json['recentActivities'] as List)
          .map((item) => Activity.fromJson(item))
          .toList(),
      achievements: (json['achievements'] as List)
          .map((item) => Achievement.fromJson(item))
          .toList(),
      achievementProgress: Map<String, double>.from(json['achievementProgress']),
      unreadNotifications: json['unreadNotifications'] ?? 0,
      hasActiveTicket: json['hasActiveTicket'] ?? false,
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  DashboardData copyWith({
    User? user,
    List<ChainMember>? chainMembers,
    DashboardStats? stats,
    List<CriticalAction>? criticalActions,
    List<Activity>? recentActivities,
    List<Achievement>? achievements,
    Map<String, double>? achievementProgress,
    int? unreadNotifications,
    bool? hasActiveTicket,
    DateTime? lastActivity,
  }) {
    return DashboardData(
      user: user ?? this.user,
      chainMembers: chainMembers ?? this.chainMembers,
      stats: stats ?? this.stats,
      criticalActions: criticalActions ?? this.criticalActions,
      recentActivities: recentActivities ?? this.recentActivities,
      achievements: achievements ?? this.achievements,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      hasActiveTicket: hasActiveTicket ?? this.hasActiveTicket,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

/// Chain member representation
class ChainMember {
  final String displayName;
  final String chainKey;
  final int position;
  final ChainMemberStatus status;
  final bool isCurrentUser;
  final String? avatarEmoji;
  final DateTime? joinedAt;
  final int? invitedCount;

  ChainMember({
    required this.displayName,
    required this.chainKey,
    required this.position,
    required this.status,
    required this.isCurrentUser,
    this.avatarEmoji,
    this.joinedAt,
    this.invitedCount,
  });

  factory ChainMember.fromJson(Map<String, dynamic> json) {
    return ChainMember(
      displayName: json['displayName'],
      chainKey: json['chainKey'],
      position: json['position'],
      status: _parseChainMemberStatus(json['status']),
      isCurrentUser: json['isCurrentUser'] ?? false,
      avatarEmoji: json['avatarEmoji'],
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      invitedCount: json['invitedCount'],
    );
  }

  static ChainMemberStatus _parseChainMemberStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return ChainMemberStatus.active;
      case 'pending':
        return ChainMemberStatus.pending;
      case 'expired':
        return ChainMemberStatus.expired;
      case 'removed':
        return ChainMemberStatus.removed;
      case 'tip':
        return ChainMemberStatus.tip;
      case 'genesis':
        return ChainMemberStatus.genesis;
      case 'milestone':
        return ChainMemberStatus.milestone;
      case 'ghost':
        return ChainMemberStatus.ghost;
      default:
        return ChainMemberStatus.active;
    }
  }
}

/// Chain member status enum
enum ChainMemberStatus {
  active,
  pending,
  expired,
  removed,
  tip,
  genesis,
  milestone,
  ghost,
}

/// Dashboard statistics
class DashboardStats {
  final int position;
  final int totalInvited;
  final int activeInvites;
  final double successRate;
  final double chainHealth;
  final int totalChainLength;
  final int wastedTickets;

  DashboardStats({
    required this.position,
    required this.totalInvited,
    required this.activeInvites,
    required this.successRate,
    required this.chainHealth,
    required this.totalChainLength,
    required this.wastedTickets,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      position: json['position'],
      totalInvited: json['totalInvited'],
      activeInvites: json['activeInvites'],
      successRate: (json['successRate'] as num).toDouble(),
      chainHealth: (json['chainHealth'] as num).toDouble(),
      totalChainLength: json['totalChainLength'],
      wastedTickets: json['wastedTickets'],
    );
  }

  String get formattedSuccessRate => '${(successRate * 100).toStringAsFixed(0)}%';
  String get formattedChainHealth => '${(chainHealth * 100).toStringAsFixed(0)}%';
}

/// Critical action that requires user attention
class CriticalAction {
  final CriticalActionType type;
  final String title;
  final String description;
  final Duration? timeRemaining;
  final VoidCallback? action;
  final IconData? icon;
  final Color? color;

  CriticalAction({
    required this.type,
    required this.title,
    required this.description,
    this.timeRemaining,
    this.action,
    this.icon,
    this.color,
  });

  factory CriticalAction.fromJson(Map<String, dynamic> json) {
    final type = _parseCriticalActionType(json['type']);
    return CriticalAction(
      type: type,
      title: json['title'],
      description: json['description'],
      timeRemaining: json['timeRemainingSeconds'] != null
          ? Duration(seconds: json['timeRemainingSeconds'])
          : null,
      icon: _getIconForType(type, json['icon']),
      color: json['color'] != null ? _parseColor(json['color']) : null,
    );
  }

  static CriticalActionType _parseCriticalActionType(String type) {
    switch (type.toLowerCase()) {
      case 'ticketexpiring':
        return CriticalActionType.ticketExpiring;
      case 'ticketexpired':
        return CriticalActionType.ticketExpired;
      case 'becametip':
        return CriticalActionType.becameTip;
      case 'chainbroken':
        return CriticalActionType.chainBroken;
      case 'inviteaccepted':
        return CriticalActionType.inviteAccepted;
      case 'inviterejected':
        return CriticalActionType.inviteRejected;
      case 'achievementunlocked':
        return CriticalActionType.achievementUnlocked;
      default:
        return CriticalActionType.becameTip;
    }
  }

  static IconData _getIconForType(CriticalActionType type, String? iconName) {
    // Map icon names from backend to Flutter icons
    switch (iconName?.toLowerCase()) {
      case 'timer':
        return Icons.timer;
      case 'star':
        return Icons.star;
      case 'warning':
        return Icons.warning;
      case 'check':
        return Icons.check_circle;
      default:
        // Fallback based on type
        switch (type) {
          case CriticalActionType.ticketExpiring:
          case CriticalActionType.ticketExpired:
            return Icons.timer_off;
          case CriticalActionType.becameTip:
            return Icons.star;
          case CriticalActionType.chainBroken:
            return Icons.warning;
          case CriticalActionType.inviteAccepted:
            return Icons.check_circle;
          case CriticalActionType.inviteRejected:
            return Icons.cancel;
          case CriticalActionType.achievementUnlocked:
            return Icons.military_tech;
        }
    }
  }

  static Color _parseColor(String colorString) {
    // Remove # if present
    final hex = colorString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

/// Critical action types
enum CriticalActionType {
  ticketExpiring,
  ticketExpired,
  becameTip,
  chainBroken,
  inviteAccepted,
  inviteRejected,
  achievementUnlocked,
}

/// Activity in the chain
class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? relatedUserId;
  final String? relatedUserName;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.relatedUserId,
    this.relatedUserName,
    this.metadata,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: _parseActivityType(json['type']),
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      relatedUserId: json['relatedUserId'],
      relatedUserName: json['relatedUserName'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  static ActivityType _parseActivityType(String type) {
    switch (type.toLowerCase()) {
      case 'newmember':
        return ActivityType.newMember;
      case 'inviteexpired':
        return ActivityType.inviteExpired;
      case 'chaingrowth':
        return ActivityType.chainGrowth;
      case 'milestone':
        return ActivityType.milestone;
      case 'ticketgenerated':
        return ActivityType.ticketGenerated;
      case 'ticketused':
        return ActivityType.ticketUsed;
      case 'becametip':
        return ActivityType.becameTip;
      case 'chainreversion':
        return ActivityType.chainReversion;
      case 'badgeearned':
        return ActivityType.badgeEarned;
      default:
        return ActivityType.ticketGenerated;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

/// Activity types
enum ActivityType {
  newMember,
  inviteExpired,
  chainGrowth,
  milestone,
  ticketGenerated,
  ticketUsed,
  becameTip,
  chainReversion,
  badgeEarned,
}

/// Achievement/Badge
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final DateTime? earnedAt;
  final double progress; // 0.0 to 1.0
  final int? targetCount;
  final int? currentCount;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    this.earnedAt,
    required this.progress,
    this.targetCount,
    this.currentCount,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      rarity: _parseAchievementRarity(json['rarity']),
      earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt']) : null,
      progress: (json['progress'] as num).toDouble(),
      targetCount: json['targetCount'],
      currentCount: json['currentCount'],
    );
  }

  static AchievementRarity _parseAchievementRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return AchievementRarity.common;
      case 'uncommon':
        return AchievementRarity.uncommon;
      case 'rare':
        return AchievementRarity.rare;
      case 'epic':
        return AchievementRarity.epic;
      case 'legendary':
        return AchievementRarity.legendary;
      default:
        return AchievementRarity.common;
    }
  }

  bool get isEarned => earnedAt != null;
  bool get isInProgress => progress > 0 && progress < 1;
  String get progressPercentage => '${(progress * 100).toStringAsFixed(0)}%';
}

/// Achievement rarity levels
enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// User preferences
class UserPreferences {
  final bool enableNotifications;
  final bool enableHaptics;
  final bool enableAnimations;
  final bool compactMode;

  UserPreferences({
    required this.enableNotifications,
    required this.enableHaptics,
    required this.enableAnimations,
    required this.compactMode,
  });

  UserPreferences copyWith({
    bool? enableNotifications,
    bool? enableHaptics,
    bool? enableAnimations,
    bool? compactMode,
  }) {
    return UserPreferences(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      compactMode: compactMode ?? this.compactMode,
    );
  }
}

/// Real-time update from WebSocket
class RealtimeUpdate {
  final RealtimeUpdateType type;
  final Map<String, dynamic> data;

  RealtimeUpdate({
    required this.type,
    required this.data,
  });
}

/// Real-time update types
enum RealtimeUpdateType {
  chainGrowth,
  newMember,
  ticketExpired,
  positionChanged,
  notification,
}

/// Extension methods for enums
extension ChainMemberStatusExtension on ChainMemberStatus {
  Color get color {
    switch (this) {
      case ChainMemberStatus.active:
        return const Color(0xFF10B981);
      case ChainMemberStatus.pending:
        return const Color(0xFFF59E0B);
      case ChainMemberStatus.expired:
      case ChainMemberStatus.removed:
        return const Color(0xFFEF4444);
      case ChainMemberStatus.tip:
        return const Color(0xFF00D4FF);
      case ChainMemberStatus.genesis:
        return const Color(0xFFFFD700);
      case ChainMemberStatus.milestone:
        return const Color(0xFF7C3AED);
      case ChainMemberStatus.ghost:
        return Colors.grey;
    }
  }

  String get label {
    switch (this) {
      case ChainMemberStatus.active:
        return 'Active';
      case ChainMemberStatus.pending:
        return 'Pending';
      case ChainMemberStatus.expired:
        return 'Expired';
      case ChainMemberStatus.removed:
        return 'Removed';
      case ChainMemberStatus.tip:
        return 'TIP';
      case ChainMemberStatus.genesis:
        return 'Genesis';
      case ChainMemberStatus.milestone:
        return 'Milestone';
      case ChainMemberStatus.ghost:
        return 'Waiting';
    }
  }
}

extension AchievementRarityExtension on AchievementRarity {
  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String get label {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

extension ActivityTypeExtension on ActivityType {
  IconData get icon {
    switch (this) {
      case ActivityType.newMember:
        return Icons.person_add;
      case ActivityType.inviteExpired:
        return Icons.timer_off;
      case ActivityType.chainGrowth:
        return Icons.trending_up;
      case ActivityType.milestone:
        return Icons.emoji_events;
      case ActivityType.ticketGenerated:
        return Icons.qr_code_2;
      case ActivityType.ticketUsed:
        return Icons.check_circle;
      case ActivityType.becameTip:
        return Icons.star;
      case ActivityType.chainReversion:
        return Icons.undo;
      case ActivityType.badgeEarned:
        return Icons.military_tech;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.newMember:
      case ActivityType.chainGrowth:
      case ActivityType.ticketUsed:
        return const Color(0xFF10B981); // emerald
      case ActivityType.inviteExpired:
      case ActivityType.chainReversion:
        return const Color(0xFFEF4444); // red
      case ActivityType.milestone:
      case ActivityType.badgeEarned:
        return const Color(0xFFFFD700); // gold
      case ActivityType.ticketGenerated:
        return const Color(0xFF7C3AED); // violet
      case ActivityType.becameTip:
        return const Color(0xFF00D4FF); // cyan
    }
  }
}