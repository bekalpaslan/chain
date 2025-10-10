// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  TaskPriority get priority => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get assignedAgent => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  TaskProgress? get progress => throw _privateConstructorUsedError;
  List<String>? get deliverables => throw _privateConstructorUsedError;
  List<String>? get dependencies => throw _privateConstructorUsedError;
  int? get estimatedHours => throw _privateConstructorUsedError;
  int? get actualHours => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    TaskStatus status,
    TaskPriority priority,
    DateTime createdAt,
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
  });

  $TaskProgressCopyWith<$Res>? get progress;
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? assignedAgent = freezed,
    Object? tags = freezed,
    Object? metadata = freezed,
    Object? progress = freezed,
    Object? deliverables = freezed,
    Object? dependencies = freezed,
    Object? estimatedHours = freezed,
    Object? actualHours = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TaskStatus,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as TaskPriority,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            assignedAgent: freezed == assignedAgent
                ? _value.assignedAgent
                : assignedAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            progress: freezed == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as TaskProgress?,
            deliverables: freezed == deliverables
                ? _value.deliverables
                : deliverables // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            dependencies: freezed == dependencies
                ? _value.dependencies
                : dependencies // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            estimatedHours: freezed == estimatedHours
                ? _value.estimatedHours
                : estimatedHours // ignore: cast_nullable_to_non_nullable
                      as int?,
            actualHours: freezed == actualHours
                ? _value.actualHours
                : actualHours // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TaskProgressCopyWith<$Res>? get progress {
    if (_value.progress == null) {
      return null;
    }

    return $TaskProgressCopyWith<$Res>(_value.progress!, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
    _$TaskImpl value,
    $Res Function(_$TaskImpl) then,
  ) = __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    TaskStatus status,
    TaskPriority priority,
    DateTime createdAt,
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
  });

  @override
  $TaskProgressCopyWith<$Res>? get progress;
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
    : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? status = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? assignedAgent = freezed,
    Object? tags = freezed,
    Object? metadata = freezed,
    Object? progress = freezed,
    Object? deliverables = freezed,
    Object? dependencies = freezed,
    Object? estimatedHours = freezed,
    Object? actualHours = freezed,
  }) {
    return _then(
      _$TaskImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TaskStatus,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as TaskPriority,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        assignedAgent: freezed == assignedAgent
            ? _value.assignedAgent
            : assignedAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        progress: freezed == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as TaskProgress?,
        deliverables: freezed == deliverables
            ? _value._deliverables
            : deliverables // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        dependencies: freezed == dependencies
            ? _value._dependencies
            : dependencies // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        estimatedHours: freezed == estimatedHours
            ? _value.estimatedHours
            : estimatedHours // ignore: cast_nullable_to_non_nullable
                  as int?,
        actualHours: freezed == actualHours
            ? _value.actualHours
            : actualHours // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.assignedAgent,
    final List<String>? tags,
    final Map<String, dynamic>? metadata,
    this.progress,
    final List<String>? deliverables,
    final List<String>? dependencies,
    this.estimatedHours,
    this.actualHours,
  }) : _tags = tags,
       _metadata = metadata,
       _deliverables = deliverables,
       _dependencies = dependencies;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final TaskStatus status;
  @override
  final TaskPriority priority;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? assignedAgent;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final TaskProgress? progress;
  final List<String>? _deliverables;
  @override
  List<String>? get deliverables {
    final value = _deliverables;
    if (value == null) return null;
    if (_deliverables is EqualUnmodifiableListView) return _deliverables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _dependencies;
  @override
  List<String>? get dependencies {
    final value = _dependencies;
    if (value == null) return null;
    if (_dependencies is EqualUnmodifiableListView) return _dependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? estimatedHours;
  @override
  final int? actualHours;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, status: $status, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt, startedAt: $startedAt, completedAt: $completedAt, assignedAgent: $assignedAgent, tags: $tags, metadata: $metadata, progress: $progress, deliverables: $deliverables, dependencies: $dependencies, estimatedHours: $estimatedHours, actualHours: $actualHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.assignedAgent, assignedAgent) ||
                other.assignedAgent == assignedAgent) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            const DeepCollectionEquality().equals(
              other._deliverables,
              _deliverables,
            ) &&
            const DeepCollectionEquality().equals(
              other._dependencies,
              _dependencies,
            ) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.actualHours, actualHours) ||
                other.actualHours == actualHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    status,
    priority,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    assignedAgent,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_metadata),
    progress,
    const DeepCollectionEquality().hash(_deliverables),
    const DeepCollectionEquality().hash(_dependencies),
    estimatedHours,
    actualHours,
  );

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(this);
  }
}

abstract class _Task implements Task {
  const factory _Task({
    required final String id,
    required final String title,
    required final String description,
    required final TaskStatus status,
    required final TaskPriority priority,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final String? assignedAgent,
    final List<String>? tags,
    final Map<String, dynamic>? metadata,
    final TaskProgress? progress,
    final List<String>? deliverables,
    final List<String>? dependencies,
    final int? estimatedHours,
    final int? actualHours,
  }) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  TaskStatus get status;
  @override
  TaskPriority get priority;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  String? get assignedAgent;
  @override
  List<String>? get tags;
  @override
  Map<String, dynamic>? get metadata;
  @override
  TaskProgress? get progress;
  @override
  List<String>? get deliverables;
  @override
  List<String>? get dependencies;
  @override
  int? get estimatedHours;
  @override
  int? get actualHours;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskProgress _$TaskProgressFromJson(Map<String, dynamic> json) {
  return _TaskProgress.fromJson(json);
}

/// @nodoc
mixin _$TaskProgress {
  int get percentage => throw _privateConstructorUsedError;
  String get currentPhase => throw _privateConstructorUsedError;
  List<ProgressEntry> get entries => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  String? get estimatedCompletion => throw _privateConstructorUsedError;

  /// Serializes this TaskProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskProgressCopyWith<TaskProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskProgressCopyWith<$Res> {
  factory $TaskProgressCopyWith(
    TaskProgress value,
    $Res Function(TaskProgress) then,
  ) = _$TaskProgressCopyWithImpl<$Res, TaskProgress>;
  @useResult
  $Res call({
    int percentage,
    String currentPhase,
    List<ProgressEntry> entries,
    DateTime? lastUpdated,
    String? estimatedCompletion,
  });
}

/// @nodoc
class _$TaskProgressCopyWithImpl<$Res, $Val extends TaskProgress>
    implements $TaskProgressCopyWith<$Res> {
  _$TaskProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentage = null,
    Object? currentPhase = null,
    Object? entries = null,
    Object? lastUpdated = freezed,
    Object? estimatedCompletion = freezed,
  }) {
    return _then(
      _value.copyWith(
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPhase: null == currentPhase
                ? _value.currentPhase
                : currentPhase // ignore: cast_nullable_to_non_nullable
                      as String,
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<ProgressEntry>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            estimatedCompletion: freezed == estimatedCompletion
                ? _value.estimatedCompletion
                : estimatedCompletion // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaskProgressImplCopyWith<$Res>
    implements $TaskProgressCopyWith<$Res> {
  factory _$$TaskProgressImplCopyWith(
    _$TaskProgressImpl value,
    $Res Function(_$TaskProgressImpl) then,
  ) = __$$TaskProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int percentage,
    String currentPhase,
    List<ProgressEntry> entries,
    DateTime? lastUpdated,
    String? estimatedCompletion,
  });
}

/// @nodoc
class __$$TaskProgressImplCopyWithImpl<$Res>
    extends _$TaskProgressCopyWithImpl<$Res, _$TaskProgressImpl>
    implements _$$TaskProgressImplCopyWith<$Res> {
  __$$TaskProgressImplCopyWithImpl(
    _$TaskProgressImpl _value,
    $Res Function(_$TaskProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentage = null,
    Object? currentPhase = null,
    Object? entries = null,
    Object? lastUpdated = freezed,
    Object? estimatedCompletion = freezed,
  }) {
    return _then(
      _$TaskProgressImpl(
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPhase: null == currentPhase
            ? _value.currentPhase
            : currentPhase // ignore: cast_nullable_to_non_nullable
                  as String,
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<ProgressEntry>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        estimatedCompletion: freezed == estimatedCompletion
            ? _value.estimatedCompletion
            : estimatedCompletion // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskProgressImpl implements _TaskProgress {
  const _$TaskProgressImpl({
    required this.percentage,
    required this.currentPhase,
    required final List<ProgressEntry> entries,
    this.lastUpdated,
    this.estimatedCompletion,
  }) : _entries = entries;

  factory _$TaskProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskProgressImplFromJson(json);

  @override
  final int percentage;
  @override
  final String currentPhase;
  final List<ProgressEntry> _entries;
  @override
  List<ProgressEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final DateTime? lastUpdated;
  @override
  final String? estimatedCompletion;

  @override
  String toString() {
    return 'TaskProgress(percentage: $percentage, currentPhase: $currentPhase, entries: $entries, lastUpdated: $lastUpdated, estimatedCompletion: $estimatedCompletion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskProgressImpl &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.currentPhase, currentPhase) ||
                other.currentPhase == currentPhase) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.estimatedCompletion, estimatedCompletion) ||
                other.estimatedCompletion == estimatedCompletion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    percentage,
    currentPhase,
    const DeepCollectionEquality().hash(_entries),
    lastUpdated,
    estimatedCompletion,
  );

  /// Create a copy of TaskProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskProgressImplCopyWith<_$TaskProgressImpl> get copyWith =>
      __$$TaskProgressImplCopyWithImpl<_$TaskProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskProgressImplToJson(this);
  }
}

abstract class _TaskProgress implements TaskProgress {
  const factory _TaskProgress({
    required final int percentage,
    required final String currentPhase,
    required final List<ProgressEntry> entries,
    final DateTime? lastUpdated,
    final String? estimatedCompletion,
  }) = _$TaskProgressImpl;

  factory _TaskProgress.fromJson(Map<String, dynamic> json) =
      _$TaskProgressImpl.fromJson;

  @override
  int get percentage;
  @override
  String get currentPhase;
  @override
  List<ProgressEntry> get entries;
  @override
  DateTime? get lastUpdated;
  @override
  String? get estimatedCompletion;

  /// Create a copy of TaskProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskProgressImplCopyWith<_$TaskProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressEntry _$ProgressEntryFromJson(Map<String, dynamic> json) {
  return _ProgressEntry.fromJson(json);
}

/// @nodoc
mixin _$ProgressEntry {
  DateTime get timestamp => throw _privateConstructorUsedError;
  int get percentage => throw _privateConstructorUsedError;
  String get phase => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get agent => throw _privateConstructorUsedError;

  /// Serializes this ProgressEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressEntryCopyWith<ProgressEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressEntryCopyWith<$Res> {
  factory $ProgressEntryCopyWith(
    ProgressEntry value,
    $Res Function(ProgressEntry) then,
  ) = _$ProgressEntryCopyWithImpl<$Res, ProgressEntry>;
  @useResult
  $Res call({
    DateTime timestamp,
    int percentage,
    String phase,
    String? note,
    String? agent,
  });
}

/// @nodoc
class _$ProgressEntryCopyWithImpl<$Res, $Val extends ProgressEntry>
    implements $ProgressEntryCopyWith<$Res> {
  _$ProgressEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? percentage = null,
    Object? phase = null,
    Object? note = freezed,
    Object? agent = freezed,
  }) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as int,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            agent: freezed == agent
                ? _value.agent
                : agent // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressEntryImplCopyWith<$Res>
    implements $ProgressEntryCopyWith<$Res> {
  factory _$$ProgressEntryImplCopyWith(
    _$ProgressEntryImpl value,
    $Res Function(_$ProgressEntryImpl) then,
  ) = __$$ProgressEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime timestamp,
    int percentage,
    String phase,
    String? note,
    String? agent,
  });
}

/// @nodoc
class __$$ProgressEntryImplCopyWithImpl<$Res>
    extends _$ProgressEntryCopyWithImpl<$Res, _$ProgressEntryImpl>
    implements _$$ProgressEntryImplCopyWith<$Res> {
  __$$ProgressEntryImplCopyWithImpl(
    _$ProgressEntryImpl _value,
    $Res Function(_$ProgressEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? percentage = null,
    Object? phase = null,
    Object? note = freezed,
    Object? agent = freezed,
  }) {
    return _then(
      _$ProgressEntryImpl(
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as int,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        agent: freezed == agent
            ? _value.agent
            : agent // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressEntryImpl implements _ProgressEntry {
  const _$ProgressEntryImpl({
    required this.timestamp,
    required this.percentage,
    required this.phase,
    this.note,
    this.agent,
  });

  factory _$ProgressEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressEntryImplFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final int percentage;
  @override
  final String phase;
  @override
  final String? note;
  @override
  final String? agent;

  @override
  String toString() {
    return 'ProgressEntry(timestamp: $timestamp, percentage: $percentage, phase: $phase, note: $note, agent: $agent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressEntryImpl &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.agent, agent) || other.agent == agent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, percentage, phase, note, agent);

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressEntryImplCopyWith<_$ProgressEntryImpl> get copyWith =>
      __$$ProgressEntryImplCopyWithImpl<_$ProgressEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressEntryImplToJson(this);
  }
}

abstract class _ProgressEntry implements ProgressEntry {
  const factory _ProgressEntry({
    required final DateTime timestamp,
    required final int percentage,
    required final String phase,
    final String? note,
    final String? agent,
  }) = _$ProgressEntryImpl;

  factory _ProgressEntry.fromJson(Map<String, dynamic> json) =
      _$ProgressEntryImpl.fromJson;

  @override
  DateTime get timestamp;
  @override
  int get percentage;
  @override
  String get phase;
  @override
  String? get note;
  @override
  String? get agent;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressEntryImplCopyWith<_$ProgressEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
