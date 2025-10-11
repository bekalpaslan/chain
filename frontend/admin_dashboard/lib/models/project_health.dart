import 'package:flutter/foundation.dart';

/// Represents the overall project health data
class ProjectHealth {
  final ProjectHealthMetadata metadata;
  final List<AgentAssessment> agentAssessments;
  final Map<String, double> categoryScores;
  final List<CriticalBlocker> criticalBlockers;
  final Recommendations recommendations;

  ProjectHealth({
    required this.metadata,
    required this.agentAssessments,
    required this.categoryScores,
    required this.criticalBlockers,
    required this.recommendations,
  });

  factory ProjectHealth.fromJson(Map<String, dynamic> json) {
    return ProjectHealth(
      metadata: ProjectHealthMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      agentAssessments: (json['agent_assessments'] as List)
          .map((e) => AgentAssessment.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryScores: (json['category_scores'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      criticalBlockers: (json['critical_blockers'] as List)
          .map((e) => CriticalBlocker.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: Recommendations.fromJson(json['recommendations'] as Map<String, dynamic>),
    );
  }
}

class ProjectHealthMetadata {
  final String lastUpdated;
  final String assessmentVersion;
  final int totalAgents;
  final double overallCompletion;

  ProjectHealthMetadata({
    required this.lastUpdated,
    required this.assessmentVersion,
    required this.totalAgents,
    required this.overallCompletion,
  });

  factory ProjectHealthMetadata.fromJson(Map<String, dynamic> json) {
    return ProjectHealthMetadata(
      lastUpdated: json['last_updated'] as String,
      assessmentVersion: json['assessment_version'] as String,
      totalAgents: json['total_agents'] as int,
      overallCompletion: (json['overall_completion'] as num).toDouble(),
    );
  }
}

class AgentAssessment {
  final String agentId;
  final String agentName;
  final double completionScore;
  final String emotion;
  final String status;
  final String assessmentSummary;
  final List<String> topPriorities;
  final List<String> criticalGaps;
  final List<String> blockers;
  final String? currentTask;

  AgentAssessment({
    required this.agentId,
    required this.agentName,
    required this.completionScore,
    required this.emotion,
    required this.status,
    required this.assessmentSummary,
    required this.topPriorities,
    required this.criticalGaps,
    required this.blockers,
    this.currentTask,
  });

  factory AgentAssessment.fromJson(Map<String, dynamic> json) {
    return AgentAssessment(
      agentId: json['agent_id'] as String,
      agentName: json['agent_name'] as String,
      completionScore: (json['completion_score'] as num).toDouble(),
      emotion: json['emotion'] as String,
      status: json['status'] as String,
      assessmentSummary: json['assessment_summary'] as String,
      topPriorities: (json['top_priorities'] as List).map((e) => e.toString()).toList(),
      criticalGaps: (json['critical_gaps'] as List).map((e) => e.toString()).toList(),
      blockers: (json['blockers'] as List).map((e) => e.toString()).toList(),
      currentTask: json['current_task'] as String?,
    );
  }
}

class CriticalBlocker {
  final String severity;
  final String area;
  final String description;
  final String impact;

  CriticalBlocker({
    required this.severity,
    required this.area,
    required this.description,
    required this.impact,
  });

  factory CriticalBlocker.fromJson(Map<String, dynamic> json) {
    return CriticalBlocker(
      severity: json['severity'] as String,
      area: json['area'] as String,
      description: json['description'] as String,
      impact: json['impact'] as String,
    );
  }
}

class Recommendations {
  final List<String> immediateActions;
  final String sprintFocus;
  final String resourceAllocation;

  Recommendations({
    required this.immediateActions,
    required this.sprintFocus,
    required this.resourceAllocation,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      immediateActions: (json['immediate_actions'] as List).map((e) => e.toString()).toList(),
      sprintFocus: json['sprint_focus'] as String,
      resourceAllocation: json['resource_allocation'] as String,
    );
  }
}
