# TASK-011: Implement Task Management UI in Admin Portal

## Overview

Build a comprehensive Flutter-based Task Management UI for the admin portal that provides real-time visibility into the backend folder-based task management system. This interface will enable administrators, project managers, and stakeholders to monitor task progress, agent workloads, deliverables, and system health through an intuitive, responsive dashboard.

The UI will mirror the backend's hierarchical task structure (`_inbox`, `_active`, `_completed`, `_archived`) and provide multiple visualization modes including list view, Kanban board, and analytics dashboards with real-time WebSocket updates.

---

## Context

### Current State
The Ticketz platform has a sophisticated backend task management system that uses a folder-based structure to organize tasks across different states. Tasks contain rich metadata including progress tracking, deliverables, logs, and agent assignments. However, there is currently **no visual interface** to interact with this system.

### Business Value
1. **Visibility**: Real-time insight into what agents are working on and task statuses
2. **Decision-Making**: Data-driven insights through analytics and metrics
3. **Planning**: Better resource allocation by viewing agent workloads
4. **Accountability**: Clear tracking of task ownership, progress, and completion
5. **Efficiency**: Reduce time spent manually checking folder structures and log files
6. **Collaboration**: Shared visibility across teams on project status

### User Personas
- **Project Managers**: Track overall progress, manage priorities, allocate resources
- **Administrators**: Monitor system health, review completed work, archive tasks
- **Stakeholders**: View high-level metrics and project status
- **Developers**: Quick access to task details, logs, and deliverables

---

## Technical Approach

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Admin Portal                      │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  Task Dashboard│  │   Task Board   │  │  Analytics   │  │
│  │     Screen     │  │     Screen     │  │   Dashboard  │  │
│  └────────┬───────┘  └────────┬───────┘  └──────┬───────┘  │
│           │                   │                  │          │
│           └───────────────────┴──────────────────┘          │
│                              │                              │
│                   ┌──────────▼──────────┐                   │
│                   │  Riverpod Providers │                   │
│                   │  (State Management) │                   │
│                   └──────────┬──────────┘                   │
│                              │                              │
│           ┌──────────────────┴──────────────────┐           │
│           │                                     │           │
│  ┌────────▼────────┐                 ┌─────────▼────────┐  │
│  │  REST API       │                 │  WebSocket       │  │
│  │  Service Layer  │                 │  Service Layer   │  │
│  └────────┬────────┘                 └─────────┬────────┘  │
│           │                                     │           │
└───────────┼─────────────────────────────────────┼───────────┘
            │                                     │
            │         Network Boundary            │
            │                                     │
┌───────────▼─────────────────────────────────────▼───────────┐
│                   Spring Boot Backend                        │
│                                                              │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │  Task Controller │              │  WebSocket       │    │
│  │  (REST API)      │              │  Handler         │    │
│  └────────┬─────────┘              └─────────┬────────┘    │
│           │                                   │             │
│           └───────────┬───────────────────────┘             │
│                       │                                     │
│              ┌────────▼────────┐                            │
│              │  Task Service   │                            │
│              └────────┬────────┘                            │
│                       │                                     │
│              ┌────────▼────────┐                            │
│              │  File System    │                            │
│              │  Task Storage   │                            │
│              └─────────────────┘                            │
└─────────────────────────────────────────────────────────────┘
```

### Data Models

All models use `freezed` for immutability, JSON serialization, and copyWith functionality.

```dart
// lib/models/task.dart

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

@freezed
class TaskMetrics with _$TaskMetrics {
  const factory TaskMetrics({
    required int totalTasks,
    required int inboxTasks,
    required int activeTasks,
    required int completedTasks,
    required int archivedTasks,
    required double averageCompletionTime,
    required Map<String, int> tasksByAgent,
    required Map<String, int> tasksByPriority,
    required List<TaskTrend> trends,
  }) = _TaskMetrics;

  factory TaskMetrics.fromJson(Map<String, dynamic> json) =>
      _$TaskMetricsFromJson(json);
}

@freezed
class TaskTrend with _$TaskTrend {
  const factory TaskTrend({
    required DateTime date,
    required int created,
    required int completed,
    required int active,
  }) = _TaskTrend;

  factory TaskTrend.fromJson(Map<String, dynamic> json) =>
      _$TaskTrendFromJson(json);
}
```

### State Management with Riverpod

```dart
// lib/providers/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketz_admin/models/task.dart';
import 'package:ticketz_admin/services/task_service.dart';

// Service provider
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});

// Tasks by status
final tasksProvider = FutureProvider.family<List<Task>, TaskStatus?>((ref, status) async {
  final service = ref.watch(taskServiceProvider);
  return service.getTasks(status: status);
});

// Single task detail
final taskDetailProvider = FutureProvider.family<Task, String>((ref, taskId) async {
  final service = ref.watch(taskServiceProvider);
  return service.getTask(taskId);
});

// Task metrics
final taskMetricsProvider = FutureProvider<TaskMetrics>((ref) async {
  final service = ref.watch(taskServiceProvider);
  return service.getMetrics();
});

// WebSocket state for real-time updates
final taskWebSocketProvider = StreamProvider<TaskUpdate>((ref) {
  final service = ref.watch(taskServiceProvider);
  return service.taskUpdatesStream;
});

// Filter state
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

@freezed
class TaskFilter with _$TaskFilter {
  const factory TaskFilter({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedAgent,
    String? searchQuery,
    TaskSortBy? sortBy,
    bool? sortAscending,
  }) = _TaskFilter;
}

enum TaskSortBy {
  createdAt,
  updatedAt,
  priority,
  title,
  progress,
}

// Filtered and sorted tasks
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final tasksAsync = ref.watch(tasksProvider(filter.status));

  return tasksAsync.whenData((tasks) {
    var filtered = tasks;

    // Apply filters
    if (filter.priority != null) {
      filtered = filtered.where((t) => t.priority == filter.priority).toList();
    }
    if (filter.assignedAgent != null) {
      filtered = filtered.where((t) => t.assignedAgent == filter.assignedAgent).toList();
    }
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query)
      ).toList();
    }

    // Apply sorting
    if (filter.sortBy != null) {
      filtered.sort((a, b) {
        int comparison;
        switch (filter.sortBy!) {
          case TaskSortBy.createdAt:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case TaskSortBy.updatedAt:
            comparison = (a.updatedAt ?? a.createdAt).compareTo(b.updatedAt ?? b.createdAt);
            break;
          case TaskSortBy.priority:
            comparison = a.priority.index.compareTo(b.priority.index);
            break;
          case TaskSortBy.title:
            comparison = a.title.compareTo(b.title);
            break;
          case TaskSortBy.progress:
            final aProgress = a.progress?.percentage ?? 0;
            final bProgress = b.progress?.percentage ?? 0;
            comparison = aProgress.compareTo(bProgress);
            break;
        }
        return filter.sortAscending == true ? comparison : -comparison;
      });
    }

    return filtered;
  });
});
```

### API Service Layer

```dart
// lib/services/task_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ticketz_admin/models/task.dart';

class TaskService {
  final Dio _dio;
  final String baseUrl;
  WebSocketChannel? _wsChannel;
  final _taskUpdatesController = StreamController<TaskUpdate>.broadcast();

  TaskService({
    Dio? dio,
    this.baseUrl = 'http://localhost:8080/api',
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  // Initialize WebSocket connection
  void connectWebSocket() {
    final wsUrl = baseUrl.replaceFirst('http', 'ws');
    _wsChannel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/tasks/updates'),
    );

    _wsChannel!.stream.listen(
      (data) {
        final update = TaskUpdate.fromJson(data);
        _taskUpdatesController.add(update);
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Attempt reconnection
        Future.delayed(const Duration(seconds: 5), connectWebSocket);
      },
      onDone: () {
        print('WebSocket connection closed');
        Future.delayed(const Duration(seconds: 5), connectWebSocket);
      },
    );
  }

  Stream<TaskUpdate> get taskUpdatesStream => _taskUpdatesController.stream;

  // Get all tasks, optionally filtered by status
  Future<List<Task>> getTasks({TaskStatus? status}) async {
    final queryParams = status != null ? {'status': status.name} : null;
    final response = await _dio.get('/tasks', queryParameters: queryParams);
    return (response.data as List).map((json) => Task.fromJson(json)).toList();
  }

  // Get single task by ID
  Future<Task> getTask(String id) async {
    final response = await _dio.get('/tasks/$id');
    return Task.fromJson(response.data);
  }

  // Create new task
  Future<Task> createTask(CreateTaskRequest request) async {
    final response = await _dio.post('/tasks', data: request.toJson());
    return Task.fromJson(response.data);
  }

  // Update task
  Future<Task> updateTask(String id, UpdateTaskRequest request) async {
    final response = await _dio.put('/tasks/$id', data: request.toJson());
    return Task.fromJson(response.data);
  }

  // Move task to different status
  Future<Task> moveTask(String id, TaskStatus newStatus) async {
    final response = await _dio.post('/tasks/$id/move', data: {'status': newStatus.name});
    return Task.fromJson(response.data);
  }

  // Get task metrics
  Future<TaskMetrics> getMetrics() async {
    final response = await _dio.get('/tasks/metrics');
    return TaskMetrics.fromJson(response.data);
  }

  // Get task logs
  Future<List<TaskLog>> getTaskLogs(String id) async {
    final response = await _dio.get('/tasks/$id/logs');
    return (response.data as List).map((json) => TaskLog.fromJson(json)).toList();
  }

  void dispose() {
    _wsChannel?.sink.close();
    _taskUpdatesController.close();
  }
}

@freezed
class TaskUpdate with _$TaskUpdate {
  const factory TaskUpdate({
    required String taskId,
    required TaskUpdateType type,
    Task? task,
    String? message,
  }) = _TaskUpdate;

  factory TaskUpdate.fromJson(Map<String, dynamic> json) =>
      _$TaskUpdateFromJson(json);
}

enum TaskUpdateType {
  created,
  updated,
  moved,
  deleted,
  progressUpdated,
}
```

---

## UI Components

### 1. Task Dashboard Overview Screen

The main entry point with view switching capabilities.

```dart
// lib/screens/task_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardView { list, board, analytics }

final dashboardViewProvider = StateProvider<DashboardView>((ref) {
  return DashboardView.list;
});

class TaskDashboardScreen extends ConsumerWidget {
  const TaskDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(dashboardViewProvider);
    final metrics = ref.watch(taskMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          // View switcher
          SegmentedButton<DashboardView>(
            segments: const [
              ButtonSegment(
                value: DashboardView.list,
                icon: Icon(Icons.list),
                label: Text('List'),
              ),
              ButtonSegment(
                value: DashboardView.board,
                icon: Icon(Icons.dashboard),
                label: Text('Board'),
              ),
              ButtonSegment(
                value: DashboardView.analytics,
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
            selected: {currentView},
            onSelectionChanged: (Set<DashboardView> newSelection) {
              ref.read(dashboardViewProvider.notifier).state = newSelection.first;
            },
          ),
          const SizedBox(width: 16),
          // Create task button
          FilledButton.icon(
            onPressed: () => _showCreateTaskDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Metrics bar
          metrics.when(
            data: (data) => _buildMetricsBar(data),
            loading: () => const LinearProgressIndicator(),
            error: (err, stack) => ErrorWidget(err),
          ),
          const Divider(height: 1),
          // Main content area
          Expanded(
            child: _buildViewContent(currentView),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsBar(TaskMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _MetricCard(
            label: 'Inbox',
            value: metrics.inboxTasks.toString(),
            icon: Icons.inbox,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          _MetricCard(
            label: 'Active',
            value: metrics.activeTasks.toString(),
            icon: Icons.play_arrow,
            color: Colors.orange,
          ),
          const SizedBox(width: 16),
          _MetricCard(
            label: 'Completed',
            value: metrics.completedTasks.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          _MetricCard(
            label: 'Avg. Completion',
            value: '${metrics.averageCompletionTime.toStringAsFixed(1)}h',
            icon: Icons.timer,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildViewContent(DashboardView view) {
    switch (view) {
      case DashboardView.list:
        return const TaskListView();
      case DashboardView.board:
        return const TaskBoardView();
      case DashboardView.analytics:
        return const AnalyticsDashboard();
    }
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    // Implementation for task creation dialog
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Task List View

Filterable, sortable, and searchable task list.

```dart
// lib/widgets/task_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);

    return Column(
      children: [
        // Filter and search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    ref.read(taskFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Priority filter
              DropdownButton<TaskPriority?>(
                value: filter.priority,
                hint: const Text('Priority'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Priorities')),
                  ...TaskPriority.values.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()),
                  )),
                ],
                onChanged: (value) {
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(priority: value);
                },
              ),
              const SizedBox(width: 16),
              // Sort options
              PopupMenuButton<TaskSortBy>(
                icon: const Icon(Icons.sort),
                onSelected: (sortBy) {
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(sortBy: sortBy);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: TaskSortBy.createdAt,
                    child: Text('Created Date'),
                  ),
                  const PopupMenuItem(
                    value: TaskSortBy.updatedAt,
                    child: Text('Updated Date'),
                  ),
                  const PopupMenuItem(
                    value: TaskSortBy.priority,
                    child: Text('Priority'),
                  ),
                  const PopupMenuItem(
                    value: TaskSortBy.progress,
                    child: Text('Progress'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Task list
        Expanded(
          child: tasksAsync.when(
            data: (tasks) => tasks.isEmpty
                ? const Center(child: Text('No tasks found'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskListItem(task: tasks[index]);
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/task/${task.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority indicator
                  _PriorityBadge(priority: task.priority),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status badge
                  Chip(
                    label: Text(task.status.name.toUpperCase()),
                    backgroundColor: _getStatusColor(task.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (task.assignedAgent != null) ...[
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(task.assignedAgent!),
                    const SizedBox(width: 16),
                  ],
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(_formatDate(task.createdAt)),
                  const Spacer(),
                  if (task.progress != null) ...[
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: task.progress!.percentage / 100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${task.progress!.percentage}%'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.inbox:
        return Colors.blue.shade100;
      case TaskStatus.active:
        return Colors.orange.shade100;
      case TaskStatus.completed:
        return Colors.green.shade100;
      case TaskStatus.archived:
        return Colors.grey.shade300;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.yellow;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }
}
```

### 3. Task Board View (Kanban)

Drag-and-drop Kanban board.

```dart
// lib/widgets/task_board_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskBoardView extends ConsumerWidget {
  const TaskBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: _TaskColumn(status: TaskStatus.inbox)),
        Expanded(child: _TaskColumn(status: TaskStatus.active)),
        Expanded(child: _TaskColumn(status: TaskStatus.completed)),
        Expanded(child: _TaskColumn(status: TaskStatus.archived)),
      ],
    );
  }
}

class _TaskColumn extends ConsumerWidget {
  final TaskStatus status;

  const _TaskColumn({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(status));

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Text(
                  status.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                tasksAsync.when(
                  data: (tasks) => CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Text(
                      tasks.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          // Task cards
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => DragTarget<Task>(
                onWillAccept: (task) => task != null && task.status != status,
                onAccept: (task) async {
                  final service = ref.read(taskServiceProvider);
                  await service.moveTask(task.id, status);
                  ref.invalidate(tasksProvider);
                },
                builder: (context, candidateData, rejectedData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _DraggableTaskCard(task: tasks[index]);
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.inbox:
        return Colors.blue;
      case TaskStatus.active:
        return Colors.orange;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.archived:
        return Colors.grey;
    }
  }
}

class _DraggableTaskCard extends StatelessWidget {
  final Task task;

  const _DraggableTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 300,
          child: _TaskCard(task: task),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TaskCard(task: task),
      ),
      child: _TaskCard(task: task),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/task/${task.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PriorityIndicator(priority: task.priority),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (task.assignedAgent != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedAgent!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (task.progress != null) ...[
                LinearProgressIndicator(
                  value: task.progress!.percentage / 100,
                ),
                const SizedBox(height: 4),
                Text(
                  '${task.progress!.percentage}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityIndicator({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.name[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.yellow.shade700;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.critical:
        return Colors.red;
    }
  }
}
```

### 4. Task Detail Screen

Comprehensive task details with tabs.

```dart
// lib/screens/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
            Tab(icon: Icon(Icons.attach_file), text: 'Deliverables'),
            Tab(icon: Icon(Icons.article), text: 'Logs'),
          ],
        ),
      ),
      body: taskAsync.when(
        data: (task) => TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(task: task),
            _ProgressTab(task: task),
            _DeliverablesTab(task: task),
            _LogsTab(taskId: widget.taskId),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Implementation
  }

  void _showOptionsMenu(BuildContext context) {
    // Implementation
  }
}

class _OverviewTab extends StatelessWidget {
  final Task task;

  const _OverviewTab({required this.task});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // Metadata cards
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Status',
                  value: task.status.name.toUpperCase(),
                  icon: Icons.flag,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  label: 'Priority',
                  value: task.priority.name.toUpperCase(),
                  icon: Icons.priority_high,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  label: 'Assigned To',
                  value: task.assignedAgent ?? 'Unassigned',
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  label: 'Created',
                  value: _formatDate(task.createdAt),
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(task.description),
          const SizedBox(height: 24),
          // Tags
          if (task.tags != null && task.tags!.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: task.tags!.map((tag) => Chip(label: Text(tag))).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  final Task task;

  const _ProgressTab({required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.progress == null) {
      return const Center(child: Text('No progress data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${task.progress!.percentage}%',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: task.progress!.percentage / 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Phase: ${task.progress!.currentPhase}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Progress history
          Text(
            'Progress History',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...task.progress!.entries.map((entry) => _ProgressEntryCard(entry: entry)),
        ],
      ),
    );
  }
}

class _ProgressEntryCard extends StatelessWidget {
  final ProgressEntry entry;

  const _ProgressEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${entry.percentage}%'),
        ),
        title: Text(entry.phase),
        subtitle: entry.note != null ? Text(entry.note!) : null,
        trailing: Text(_formatDateTime(entry.timestamp)),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DeliverablesTab extends StatelessWidget {
  final Task task;

  const _DeliverablesTab({required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.deliverables == null || task.deliverables!.isEmpty) {
      return const Center(child: Text('No deliverables'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: task.deliverables!.length,
      itemBuilder: (context, index) {
        final deliverable = task.deliverables![index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(deliverable),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Download deliverable
              },
            ),
          ),
        );
      },
    );
  }
}

class _LogsTab extends ConsumerWidget {
  final String taskId;

  const _LogsTab({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This would use a separate provider for task logs
    return const Center(child: Text('Logs tab implementation'));
  }
}
```

### 5. Analytics Dashboard

Metrics and visualizations.

```dart
// lib/widgets/analytics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboard extends ConsumerWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(taskMetricsProvider);

    return metricsAsync.when(
      data: (metrics) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task distribution pie chart
            _buildSectionTitle(context, 'Task Distribution'),
            SizedBox(
              height: 300,
              child: _TaskDistributionChart(metrics: metrics),
            ),
            const SizedBox(height: 32),
            // Task trends line chart
            _buildSectionTitle(context, 'Task Trends (Last 30 Days)'),
            SizedBox(
              height: 300,
              child: _TaskTrendsChart(trends: metrics.trends),
            ),
            const SizedBox(height: 32),
            // Agent workload
            _buildSectionTitle(context, 'Agent Workload'),
            _AgentWorkloadChart(tasksByAgent: metrics.tasksByAgent),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _TaskDistributionChart extends StatelessWidget {
  final TaskMetrics metrics;

  const _TaskDistributionChart({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: metrics.inboxTasks.toDouble(),
            title: 'Inbox\n${metrics.inboxTasks}',
            color: Colors.blue,
            radius: 100,
          ),
          PieChartSectionData(
            value: metrics.activeTasks.toDouble(),
            title: 'Active\n${metrics.activeTasks}',
            color: Colors.orange,
            radius: 100,
          ),
          PieChartSectionData(
            value: metrics.completedTasks.toDouble(),
            title: 'Completed\n${metrics.completedTasks}',
            color: Colors.green,
            radius: 100,
          ),
          PieChartSectionData(
            value: metrics.archivedTasks.toDouble(),
            title: 'Archived\n${metrics.archivedTasks}',
            color: Colors.grey,
            radius: 100,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

class _TaskTrendsChart extends StatelessWidget {
  final List<TaskTrend> trends;

  const _TaskTrendsChart({required this.trends});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: trends.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.created.toDouble());
            }).toList(),
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: trends.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.completed.toDouble());
            }).toList(),
            color: Colors.green,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: trends.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.active.toDouble());
            }).toList(),
            color: Colors.orange,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}

class _AgentWorkloadChart extends StatelessWidget {
  final Map<String, int> tasksByAgent;

  const _AgentWorkloadChart({required this.tasksByAgent});

  @override
  Widget build(BuildContext context) {
    final entries = tasksByAgent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        final maxTasks = entries.first.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / maxTasks,
                  minHeight: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.value} tasks',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
```

---

## Acceptance Criteria

1. **Task List View**
   - [ ] Display all tasks in a scrollable list with filtering by status, priority, and agent
   - [ ] Search functionality filters tasks by title and description in real-time
   - [ ] Sort tasks by created date, updated date, priority, or progress percentage
   - [ ] Each task card shows: title, description snippet, status, priority, assigned agent, creation date, and progress bar
   - [ ] Clicking a task navigates to the detail screen

2. **Task Board View**
   - [ ] Display four columns: Inbox, Active, Completed, Archived
   - [ ] Each column shows task count in header
   - [ ] Tasks can be dragged between columns to change status
   - [ ] Column headers are color-coded (blue, orange, green, grey)
   - [ ] Dragging updates the backend via API and reflects changes immediately

3. **Task Detail View**
   - [ ] Overview tab displays all task metadata (status, priority, agent, dates, description, tags)
   - [ ] Progress tab shows current percentage, phase, and historical progress entries
   - [ ] Deliverables tab lists all attached files with download capability
   - [ ] Logs tab displays task execution logs with timestamps
   - [ ] Edit button allows updating task properties
   - [ ] Options menu provides actions (archive, delete, assign, etc.)

4. **Real-time Updates**
   - [ ] WebSocket connection established on app start
   - [ ] Task creation/updates reflected in UI within 2 seconds without page refresh
   - [ ] Toast notifications show when tasks are updated by other users
   - [ ] Automatic reconnection when WebSocket connection drops
   - [ ] Optimistic UI updates for user actions

5. **Analytics Dashboard**
   - [ ] Pie chart showing task distribution across statuses
   - [ ] Line chart displaying 30-day trend of created/completed/active tasks
   - [ ] Bar chart showing agent workload (tasks per agent)
   - [ ] Key metrics cards: total tasks, avg completion time, tasks by priority
   - [ ] All charts are interactive and responsive

6. **Task Creation**
   - [ ] Modal dialog with form fields: title, description, priority, assigned agent, tags
   - [ ] Form validation ensures required fields are filled
   - [ ] Successfully created tasks appear in Inbox immediately
   - [ ] Error handling displays user-friendly messages

7. **Performance**
   - [ ] Initial load completes in < 2 seconds for up to 1000 tasks
   - [ ] Filtering/sorting operations complete in < 500ms
   - [ ] Smooth 60fps animations for drag-and-drop
   - [ ] List view uses lazy loading for efficient rendering

8. **Design & UX**
   - [ ] Consistent Material Design 3 styling throughout
   - [ ] Responsive layout works on desktop (1920x1080+) and tablet (768px+)
   - [ ] Loading states with skeleton screens or spinners
   - [ ] Error states with retry options
   - [ ] Accessible with proper ARIA labels and keyboard navigation

9. **State Management**
   - [ ] All data fetching uses Riverpod providers
   - [ ] Provider invalidation on mutations ensures data consistency
   - [ ] Cache invalidation strategy prevents stale data
   - [ ] Minimal unnecessary re-renders

10. **Testing**
    - [ ] Unit tests for all data models and business logic
    - [ ] Widget tests for all major UI components
    - [ ] Integration tests for critical user flows (create task, move task, filter tasks)
    - [ ] Test coverage > 80%

---

## Dependencies

### Task Dependencies
- **TASK-009**: Backend Task Management API must be completed first to provide REST and WebSocket endpoints

### Technical Dependencies

**Required Flutter Packages:**
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Networking
  dio: ^5.4.0
  web_socket_channel: ^2.4.0

  # Charts & Visualization
  fl_chart: ^0.66.0

  # UI Components
  flutter_slidable: ^3.0.1
  badges: ^3.1.2

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

### API Endpoints

The following backend endpoints must be available:

**REST API:**
- `GET /api/tasks` - Get all tasks (with optional status filter)
- `GET /api/tasks/{id}` - Get single task
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task
- `POST /api/tasks/{id}/move` - Move task to different status
- `GET /api/tasks/metrics` - Get task metrics and analytics
- `GET /api/tasks/{id}/logs` - Get task execution logs

**WebSocket:**
- `ws://localhost:8080/api/tasks/updates` - Real-time task updates stream

---

## Resources

### Design References
- **Mission Control Center Aesthetic**: NASA mission control dashboards
- **Jira Task Board**: Reference for Kanban drag-and-drop UX
- **Linear App**: Clean, modern task management UI inspiration
- **Material Design 3**: Official design system guidelines

### Documentation
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [Freezed Package Documentation](https://pub.dev/packages/freezed)
- [FL Chart Examples](https://pub.dev/packages/fl_chart)
- [WebSocket Channel Usage](https://pub.dev/packages/web_socket_channel)

### Backend Integration
- Backend task folder structure: `.claude/tasks/{_inbox,_active,_completed,_archived}/`
- Task metadata format in `metadata.json`
- Progress tracking in `progress.log`
- Deliverables stored in `deliverables/` subdirectory

---

## Testing Strategy

### Unit Tests
```dart
// test/models/task_test.dart
void main() {
  group('Task Model', () {
    test('fromJson creates valid Task instance', () {
      final json = {
        'id': 'TASK-001',
        'title': 'Test Task',
        'description': 'Test Description',
        'status': 'active',
        'priority': 'high',
        'createdAt': '2025-01-01T00:00:00Z',
      };

      final task = Task.fromJson(json);

      expect(task.id, 'TASK-001');
      expect(task.status, TaskStatus.active);
      expect(task.priority, TaskPriority.high);
    });

    test('copyWith creates new instance with updated fields', () {
      final task = Task(/* ... */);
      final updated = task.copyWith(status: TaskStatus.completed);

      expect(updated.status, TaskStatus.completed);
      expect(updated.id, task.id);
    });
  });
}

// test/providers/task_providers_test.dart
void main() {
  group('Task Providers', () {
    test('tasksProvider fetches tasks from service', () async {
      final container = ProviderContainer(
        overrides: [
          taskServiceProvider.overrideWithValue(MockTaskService()),
        ],
      );

      final tasks = await container.read(tasksProvider(null).future);

      expect(tasks, isNotEmpty);
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/task_list_view_test.dart
void main() {
  testWidgets('TaskListView displays tasks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredTasksProvider.overrideWith((ref) {
            return AsyncValue.data([/* mock tasks */]);
          }),
        ],
        child: MaterialApp(home: TaskListView()),
      ),
    );

    expect(find.byType(TaskListItem), findsWidgets);
  });

  testWidgets('Search filter updates task list', (tester) async {
    // Test search functionality
  });
}
```

### Integration Tests
```dart
// integration_test/task_flow_test.dart
void main() {
  testWidgets('Complete task creation flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to dashboard
    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('title-field')), 'Test Task');
    await tester.enterText(find.byKey(Key('description-field')), 'Description');

    // Submit
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Verify task appears in list
    expect(find.text('Test Task'), findsOneWidget);
  });
}
```

---

## Rollback Plan

If critical issues arise during or after deployment:

1. **Immediate Actions**
   - Disable real-time WebSocket features via feature flag
   - Revert to read-only mode (disable task creation/updates)
   - Display maintenance banner to users

2. **Graceful Degradation**
   - If WebSocket fails, fall back to polling every 30 seconds
   - If charts fail to render, show tabular data instead
   - If drag-and-drop fails, provide dropdown for status changes

3. **Data Safety**
   - All mutations go through backend API (no local-only state)
   - No risk of data loss as UI is read-only client
   - Backend task files remain authoritative source

4. **Rollback Steps**
   ```bash
   # Revert to previous version
   git checkout <previous-commit>

   # Rebuild Flutter web
   flutter build web --release

   # Deploy previous version
   # (deployment commands specific to hosting platform)
   ```

5. **Communication**
   - Notify users via in-app banner of temporary limitations
   - Post status update on internal communications channel
   - Document issues in incident log for post-mortem

---

## Definition of Done

- [ ] All acceptance criteria met and verified
- [ ] Code passes all unit, widget, and integration tests (>80% coverage)
- [ ] Code reviewed and approved by at least one team member
- [ ] UI/UX reviewed and approved by design team
- [ ] Performance benchmarks met (load time, rendering, animations)
- [ ] Accessibility audit passed (keyboard navigation, screen readers)
- [ ] Documentation completed:
  - [ ] Code comments for complex logic
  - [ ] User guide for task management features
  - [ ] API integration documentation
- [ ] Successfully tested in staging environment
- [ ] WebSocket reconnection logic tested with network interruptions
- [ ] Error handling verified for all API failure scenarios
- [ ] Real-time updates confirmed working with multiple concurrent users
- [ ] Responsive design verified on desktop (1920x1080) and tablet (768px)
- [ ] Cross-browser testing completed (Chrome, Firefox, Safari, Edge)
- [ ] Production deployment completed
- [ ] Monitoring and alerting configured
- [ ] Stakeholder demo completed and approved

---

## Notes

### Design Philosophy
This UI embodies a "**mission control center**" aesthetic - providing comprehensive visibility and control over the task management system. The design prioritizes:

- **Information density without clutter**: Show relevant data prominently
- **Actionable insights**: Every metric should drive decisions
- **Real-time awareness**: Users should feel connected to live system state
- **Efficient workflows**: Minimize clicks to accomplish common tasks
- **Visual hierarchy**: Most important info (status, progress) is most prominent

### Performance Considerations

1. **Lazy Loading**: Task lists use `ListView.builder` for efficient rendering of large datasets
2. **Debouncing**: Search input debounced by 300ms to reduce unnecessary API calls
3. **Pagination**: Backend should support pagination; implement infinite scroll if task count > 500
4. **Caching**: Riverpod's built-in caching reduces redundant API calls
5. **Optimistic Updates**: UI updates immediately on user actions, then syncs with backend

### Future Enhancements

**Phase 2 (Post-MVP):**
- Task templates for common workflows
- Bulk operations (assign multiple tasks, bulk status changes)
- Advanced filters (date ranges, custom queries)
- Task dependencies visualization (graph view)
- Export tasks to CSV/PDF
- Commenting system on tasks
- File upload for deliverables
- Email notifications for task updates
- Custom dashboard layouts (user preferences)

**Phase 3 (Advanced):**
- AI-powered task recommendations
- Predictive completion time estimates
- Automated task routing based on agent expertise
- Integration with external tools (Slack, GitHub, Jira)
- Mobile app (iOS/Android)
- Offline support with sync
- Advanced analytics (burndown charts, velocity tracking)
- Custom workflows and automation rules

---

**Document Version**: 1.0
**Last Updated**: 2025-10-10
**Author**: Development Team
**Status**: Ready for Implementation
