import 'package:flutter/material.dart';

class AgentStatus {
  final String id;
  final String name;
  final String role;
  final String status; // active, idle, blocked, working
  final String emotion; // happy, sad, neutral, frustrated, satisfied
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

    return AgentStatus(
      id: id,
      name: displayName,
      role: role,
      status: json['status'] ?? 'idle',
      emotion: json['emotion'] ?? 'neutral',
      currentTask: json['current_task'],
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
      case 'neutral':
      default:
        return '😐';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return const Color(0xFF00E5FF); // Ghost Cyan
      case 'working':
        return const Color(0xFF4CAF50); // Green Glow
      case 'blocked':
        return const Color(0xFFF44336); // Red Pulse
      case 'idle':
      default:
        return const Color(0xFF9B59B6); // Mystic Violet
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'active':
        return Icons.flash_on;
      case 'working':
        return Icons.engineering;
      case 'blocked':
        return Icons.block;
      case 'idle':
      default:
        return Icons.schedule;
    }
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