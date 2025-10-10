// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  assignedAgent: json['assignedAgent'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  progress: json['progress'] == null
      ? null
      : TaskProgress.fromJson(json['progress'] as Map<String, dynamic>),
  deliverables: (json['deliverables'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  dependencies: (json['dependencies'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedHours: (json['estimatedHours'] as num?)?.toInt(),
  actualHours: (json['actualHours'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'assignedAgent': instance.assignedAgent,
      'tags': instance.tags,
      'metadata': instance.metadata,
      'progress': instance.progress,
      'deliverables': instance.deliverables,
      'dependencies': instance.dependencies,
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.inbox: 'inbox',
  TaskStatus.active: 'active',
  TaskStatus.completed: 'completed',
  TaskStatus.archived: 'archived',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.critical: 'critical',
};

_$TaskProgressImpl _$$TaskProgressImplFromJson(Map<String, dynamic> json) =>
    _$TaskProgressImpl(
      percentage: (json['percentage'] as num).toInt(),
      currentPhase: json['currentPhase'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      estimatedCompletion: json['estimatedCompletion'] as String?,
    );

Map<String, dynamic> _$$TaskProgressImplToJson(_$TaskProgressImpl instance) =>
    <String, dynamic>{
      'percentage': instance.percentage,
      'currentPhase': instance.currentPhase,
      'entries': instance.entries,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'estimatedCompletion': instance.estimatedCompletion,
    };

_$ProgressEntryImpl _$$ProgressEntryImplFromJson(Map<String, dynamic> json) =>
    _$ProgressEntryImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      percentage: (json['percentage'] as num).toInt(),
      phase: json['phase'] as String,
      note: json['note'] as String?,
      agent: json['agent'] as String?,
    );

Map<String, dynamic> _$$ProgressEntryImplToJson(_$ProgressEntryImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'percentage': instance.percentage,
      'phase': instance.phase,
      'note': instance.note,
      'agent': instance.agent,
    };
