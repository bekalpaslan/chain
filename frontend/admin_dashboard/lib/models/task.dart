import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? assignedAgent,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    TaskProgress? progress,
    List<String>? deliverables,
    List<String>? dependencies,
    int? estimatedHours,
    int? actualHours,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum TaskStatus {
  @JsonValue('inbox')
  inbox,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('archived')
  archived,
}

enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
class TaskProgress with _$TaskProgress {
  const factory TaskProgress({
    required int percentage,
    required String currentPhase,
    required List<ProgressEntry> entries,
    DateTime? lastUpdated,
    String? estimatedCompletion,
  }) = _TaskProgress;

  factory TaskProgress.fromJson(Map<String, dynamic> json) =>
      _$TaskProgressFromJson(json);
}

@freezed
class ProgressEntry with _$ProgressEntry {
  const factory ProgressEntry({
    required DateTime timestamp,
    required int percentage,
    required String phase,
    String? note,
    String? agent,
  }) = _ProgressEntry;

  factory ProgressEntry.fromJson(Map<String, dynamic> json) =>
      _$ProgressEntryFromJson(json);
}
