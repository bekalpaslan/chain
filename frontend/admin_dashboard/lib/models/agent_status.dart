import 'package:flutter/material.dart';
import '../theme/dark_mystique_theme.dart';

class AgentStatus {
  final String id;
  final String name;
  final String role;
  final String status; // in_progress, focused, idle, blocked
  final String emotion; // happy, sad, neutral, frustrated, satisfied, focused
  final String? currentTask;
  final DateTime lastActivity;
  final double? progress;

  AgentStatus({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.emotion,
    this.currentTask,
    required this.lastActivity,
    this.progress,
  });

  factory AgentStatus.fromJson(String id, Map<String, dynamic> json) {
    // Convert agent ID to display name
    final displayName = _getDisplayName(id);
    final role = _getRole(id);

    // Parse current_task which can be null or an object with id/title
    String? currentTask;
    if (json['current_task'] != null) {
      if (json['current_task'] is String) {
        currentTask = json['current_task'];
      } else if (json['current_task'] is Map) {
        currentTask = json['current_task']['title'] ?? json['current_task']['id'];
      }
    }

    return AgentStatus(
      id: id,
      name: displayName,
      role: role,
      status: json['status'] ?? 'idle',
      emotion: json['emotion'] ?? 'neutral',
      currentTask: currentTask,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : DateTime.now(),
      progress: json['progress']?.toDouble(),
    );
  }

  static String _getDisplayName(String id) {
    final parts = id.split('-');
    return parts.map((part) =>
      part[0].toUpperCase() + part.substring(1)
    ).join(' ');
  }

  static String _getRole(String id) {
    final roleMap = {
      'technical-project-manager': 'Project Management',
      'solution-architect': 'System Architecture',
      'senior-backend-engineer': 'Backend Development',
      'principal-database-architect': 'Database Design',
      'lead-qa-engineer': 'Quality Assurance',
      'devops-lead': 'DevOps & Infrastructure',
      'senior-ui-ux-designer': 'UI/UX Design',
      'senior-frontend-engineer': 'Frontend Development',
      'senior-mobile-developer': 'Mobile Development',
      'scrum-master': 'Agile Facilitation',
      'product-strategist': 'Product Strategy',
      'ux-psychology-specialist': 'User Psychology',
      'game-theory-analyst': 'Game Theory',
      'legal-compliance-advisor': 'Legal & Compliance',
    };
    return roleMap[id] ?? 'Team Member';
  }

  String get emotionEmoji {
    switch (emotion) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😔';
      case 'frustrated':
        return '😤';
      case 'satisfied':
        return '😌';
      case 'focused':
        return '🎯';
      case 'neutral':
      default:
        return '😐';
    }
  }

  /// Get status color using Material Design palette
  /// Designed for accessibility (4.5:1 contrast ratio minimum)
  Color get statusColor {
    switch (status) {
      case 'in_progress':
      case 'active':
      case 'working':
        return DarkMystiqueTheme.statusInProgress; // Green - active work
      case 'focused':
        return DarkMystiqueTheme.statusFocused; // Amber - concentration
      case 'blocked':
        return DarkMystiqueTheme.statusBlocked; // Red - cannot proceed
      case 'satisfied':
        return DarkMystiqueTheme.statusSatisfied; // Light Blue - completed
      case 'idle':
      default:
        return DarkMystiqueTheme.statusIdle; // Gray - no active work
    }
  }

  /// Get emotion-based color overlay (for cards with emotion indicators)
  Color get emotionColor {
    switch (emotion) {
      case 'happy':
        return DarkMystiqueTheme.statusHappy; // Light Green
      case 'satisfied':
        return DarkMystiqueTheme.statusSatisfied; // Light Blue
      case 'frustrated':
        return DarkMystiqueTheme.statusBlocked; // Red
      case 'focused':
        return DarkMystiqueTheme.statusFocused; // Amber
      case 'sad':
        return DarkMystiqueTheme.textMuted; // Muted gray
      case 'neutral':
      default:
        return DarkMystiqueTheme.statusIdle; // Neutral gray
    }
  }

  /// Get status icon with semantic meaning
  /// Ensures accessibility for color-blind users
  IconData get statusIcon {
    switch (status) {
      case 'in_progress':
      case 'active':
      case 'working':
        return Icons.bolt; // ⚡ Lightning bolt - active
      case 'focused':
        return Icons.center_focus_strong; // 🎯 Target - focused
      case 'blocked':
        return Icons.warning_amber_rounded; // ⚠ Warning - blocked
      case 'satisfied':
        return Icons.check_circle; // ✓ Checkmark - satisfied
      case 'idle':
      default:
        return Icons.pause_circle_outline; // ⏸ Pause - idle
    }
  }

  /// Get human-readable status text
  String get statusText {
    switch (status) {
      case 'in_progress':
        return 'IN PROGRESS';
      case 'active':
        return 'ACTIVE';
      case 'working':
        return 'WORKING';
      case 'focused':
        return 'FOCUSED';
      case 'blocked':
        return 'BLOCKED';
      case 'satisfied':
        return 'SATISFIED';
      case 'idle':
      default:
        return 'IDLE';
    }
  }

  /// Check if agent should have pulse animation
  bool get shouldPulse {
    return status == 'in_progress' ||
        status == 'active' ||
        status == 'working' ||
        status == 'focused';
  }

  String get timeSinceLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inSeconds < 60) {
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

class ProjectStatus {
  final String health;
  final String activeSprint;
  final String sprintId;
  final int sprintProgress;
  final int activeTasks;
  final int criticalTasks;
  final int highPriorityTasks;
  final int totalStoryPoints;
  final int completedPoints;
  final DateTime lastUpdated;

  ProjectStatus({
    required this.health,
    required this.activeSprint,
    required this.sprintId,
    required this.sprintProgress,
    required this.activeTasks,
    required this.criticalTasks,
    required this.highPriorityTasks,
    required this.totalStoryPoints,
    required this.completedPoints,
    required this.lastUpdated,
  });

  factory ProjectStatus.fromJson(Map<String, dynamic> json) {
    final projectData = json['project_status'] ?? {};
    final taskSystem = projectData['task_system'] ?? {};

    return ProjectStatus(
      health: projectData['health'] ?? 'unknown',
      activeSprint: projectData['active_sprint'] ?? 'No active sprint',
      sprintId: projectData['sprint_id'] ?? '',
      sprintProgress: projectData['sprint_progress'] ?? 0,
      activeTasks: taskSystem['active_tasks'] ?? 0,
      criticalTasks: taskSystem['critical_tasks'] ?? 0,
      highPriorityTasks: taskSystem['high_priority_tasks'] ?? 0,
      totalStoryPoints: taskSystem['total_story_points'] ?? 0,
      completedPoints: taskSystem['completed_points'] ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Color get healthColor {
    switch (health) {
      case 'healthy':
        return const Color(0xFF4CAF50); // Green
      case 'warning':
        return const Color(0xFFFF9800); // Orange
      case 'critical':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9B59B6); // Purple
    }
  }

  IconData get healthIcon {
    switch (health) {
      case 'healthy':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}