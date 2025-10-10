# Task: FE-001 - Implement Project Board Dashboard

## 🎯 Task Assignment
**Assigned To**: Senior Frontend Engineer
**Priority**: High
**Sprint**: Current
**Estimated Story Points**: 13
**Dependencies**: UI-001 Design Mockups (In Progress)
**Status**: Ready for Development

## 📋 Task Description
Implement a real-time project board dashboard for The Chain development team using Flutter Web. The dashboard will display agent statuses, project metrics, activity logs, and system health using the existing Mystique dark theme components.

## 🛠 Technical Requirements

### Technology Stack
- **Framework**: Flutter Web (Flutter 3.9.2+)
- **State Management**: Riverpod 2.0
- **Real-time**: web_socket_channel package
- **HTTP**: Dio (already in shared library)
- **Charts**: fl_chart ^0.66.0
- **Animations**: Flutter built-in animation framework

### Project Structure
```
frontend/admin-dashboard/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── routes.dart
│   │   └── websocket_config.dart
│   ├── models/
│   │   ├── agent_status.dart
│   │   ├── project_metrics.dart
│   │   └── activity_log.dart
│   ├── providers/
│   │   ├── agent_provider.dart
│   │   ├── metrics_provider.dart
│   │   └── websocket_provider.dart
│   ├── screens/
│   │   └── project_board/
│   │       ├── project_board_screen.dart
│   │       └── widgets/
│   │           ├── agent_grid.dart
│   │           ├── agent_card.dart
│   │           ├── project_overview.dart
│   │           ├── quick_stats.dart
│   │           ├── activity_timeline.dart
│   │           └── system_health.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── websocket_service.dart
│   │   └── log_parser_service.dart
│   └── utils/
│       ├── formatters.dart
│       └── constants.dart
├── test/
├── assets/
└── pubspec.yaml
```

## 📦 Implementation Steps

### Phase 1: Project Setup (Day 1)

#### 1.1 Create New Flutter Web Project
```bash
cd frontend
flutter create --platforms=web admin-dashboard
cd admin-dashboard
```

#### 1.2 Add Dependencies to pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  thechain_shared:
    path: ../shared
  flutter_riverpod: ^2.4.9
  web_socket_channel: ^2.4.0
  fl_chart: ^0.66.0
  intl: ^0.18.1
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  mocktail: ^1.0.1
```

### Phase 2: Data Models (Day 1-2)

#### 2.1 Agent Status Model
```dart
// lib/models/agent_status.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_status.freezed.dart';
part 'agent_status.g.dart';

@freezed
class AgentStatus with _$AgentStatus {
  const factory AgentStatus({
    required String id,
    required String name,
    required String displayName,
    required String role,
    required AgentState status,
    required EmotionState emotion,
    String? currentTask,
    required DateTime lastActivity,
    double? progress,
  }) = _AgentStatus;

  factory AgentStatus.fromJson(Map<String, dynamic> json) =>
      _$AgentStatusFromJson(json);
}

enum AgentState { active, idle, blocked, working }
enum EmotionState { happy, sad, neutral, frustrated, satisfied }
```

#### 2.2 Project Metrics Model
```dart
// lib/models/project_metrics.dart
@freezed
class ProjectMetrics with _$ProjectMetrics {
  const factory ProjectMetrics({
    required int currentSprint,
    required String sprintName,
    required double progress,
    required int daysRemaining,
    required double velocity,
    required TaskStats taskStats,
  }) = _ProjectMetrics;
}

@freezed
class TaskStats with _$TaskStats {
  const factory TaskStats({
    required int total,
    required int completed,
    required int inProgress,
    required int blocked,
    required int pending,
  }) = _TaskStats;
}
```

### Phase 3: State Management (Day 2-3)

#### 3.1 WebSocket Provider
```dart
// lib/providers/websocket_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final websocketProvider = Provider<WebSocketChannel>((ref) {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080/api/v1/ws/dashboard'),
  );

  ref.onDispose(() => channel.sink.close());

  return channel;
});

final agentStreamProvider = StreamProvider<List<AgentStatus>>((ref) {
  final ws = ref.watch(websocketProvider);

  return ws.stream
      .map((data) => jsonDecode(data))
      .where((json) => json['type'] == 'agent_update')
      .map((json) => (json['agents'] as List)
          .map((a) => AgentStatus.fromJson(a))
          .toList());
});
```

#### 3.2 Agent Status Provider
```dart
// lib/providers/agent_provider.dart
final agentStatusProvider = StateNotifierProvider<AgentStatusNotifier, AsyncValue<List<AgentStatus>>>((ref) {
  return AgentStatusNotifier(ref);
});

class AgentStatusNotifier extends StateNotifier<AsyncValue<List<AgentStatus>>> {
  final Ref ref;
  Timer? _pollingTimer;

  AgentStatusNotifier(this.ref) : super(const AsyncLoading()) {
    _init();
  }

  void _init() {
    // Try WebSocket first
    ref.listen(agentStreamProvider, (previous, next) {
      next.when(
        data: (agents) => state = AsyncData(agents),
        error: (e, s) => _fallbackToPolling(),
        loading: () => state = const AsyncLoading(),
      );
    });
  }

  void _fallbackToPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAgentStatus();
    });
  }

  Future<void> _fetchAgentStatus() async {
    try {
      final response = await ref.read(apiServiceProvider).getAgentStatus();
      state = AsyncData(response);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
```

### Phase 4: UI Components (Day 3-5)

#### 4.1 Main Project Board Screen
```dart
// lib/screens/project_board/project_board_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';

class ProjectBoardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DarkMystiqueTheme.voidBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DarkMystiqueTheme.voidBlack,
              DarkMystiqueTheme.shadowPurple.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1400) {
                    return _buildDesktopLayout(ref);
                  } else if (constraints.maxWidth > 768) {
                    return _buildTabletLayout(ref);
                  }
                  return _buildMobileLayout(ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              ProjectOverviewCard(),
              const SizedBox(height: 24),
              Expanded(child: AgentGrid()),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              QuickStatsPanel(),
              const SizedBox(height: 24),
              SystemHealthPanel(),
              const SizedBox(height: 24),
              Expanded(child: ActivityTimeline()),
            ],
          ),
        ),
      ],
    );
  }
}
```

#### 4.2 Agent Card Component
```dart
// lib/screens/project_board/widgets/agent_card.dart
class AgentCard extends ConsumerWidget {
  final AgentStatus agent;

  const AgentCard({required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: MystiqueCard(
        elevated: agent.status == AgentState.active,
        onTap: () => _showAgentDetails(context),
        child: Stack(
          children: [
            // Status indicator border
            if (agent.status == AgentState.active)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(),
                      width: 2,
                    ),
                  ),
                ),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and status
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            agent.displayName,
                            style: TextStyle(
                              color: DarkMystiqueTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            agent.role,
                            style: TextStyle(
                              color: DarkMystiqueTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEmotionIndicator(),
                  ],
                ),

                const SizedBox(height: 16),

                // Status and Task
                _buildStatusBadge(),

                const SizedBox(height: 8),

                if (agent.currentTask != null) ...[
                  Text(
                    'Current Task:',
                    style: TextStyle(
                      color: DarkMystiqueTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agent.currentTask!,
                    style: TextStyle(
                      color: DarkMystiqueTheme.textPrimary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const Spacer(),

                // Progress bar
                if (agent.progress != null)
                  _buildProgressBar(),

                // Last activity
                Text(
                  'Last active: ${_formatTime(agent.lastActivity)}',
                  style: TextStyle(
                    color: DarkMystiqueTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionIndicator() {
    final emoji = switch (agent.emotion) {
      EmotionState.happy => '😊',
      EmotionState.sad => '😔',
      EmotionState.frustrated => '😤',
      EmotionState.satisfied => '😌',
      _ => '😐',
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getEmotionColor().withOpacity(0.2),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}
```

### Phase 5: Real-time Features (Day 5-6)

#### 5.1 Activity Timeline
```dart
// lib/screens/project_board/widgets/activity_timeline.dart
class ActivityTimeline extends ConsumerStatefulWidget {
  @override
  _ActivityTimelineState createState() => _ActivityTimelineState();
}

class _ActivityTimelineState extends ConsumerState<ActivityTimeline> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  List<ActivityLog> _logs = [];

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(activityLogsProvider);

    return MystiqueCard(
      child: Column(
        children: [
          // Header with filters
          Row(
            children: [
              Text(
                'Activity Timeline',
                style: TextStyle(
                  color: DarkMystiqueTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: _autoScroll,
                onChanged: (v) => setState(() => _autoScroll = v),
                activeColor: DarkMystiqueTheme.ghostCyan,
              ),
              Text('Auto-scroll', style: TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 16),

          // Logs list
          Expanded(
            child: logsAsync.when(
              data: (logs) => ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildLogEntry(log);
                },
              ),
              loading: () => Center(child: MystiqueLoadingIndicator()),
              error: (e, s) => MystiqueAlert(
                message: 'Failed to load activity logs',
                type: MystiqueAlertType.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(ActivityLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          SizedBox(
            width: 60,
            child: Text(
              DateFormat('HH:mm:ss').format(log.timestamp),
              style: TextStyle(
                color: DarkMystiqueTheme.textMuted,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Agent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.etherealPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              log.agent,
              style: TextStyle(
                color: DarkMystiqueTheme.etherealPurple,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Message
          Expanded(
            child: Text(
              log.message,
              style: TextStyle(
                color: _getLogColor(log.type),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Phase 6: System Health Monitoring (Day 6)

#### 6.1 System Health Panel
```dart
// lib/screens/project_board/widgets/system_health.dart
class SystemHealthPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(systemHealthProvider);

    return MystiqueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health',
            style: TextStyle(
              color: DarkMystiqueTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          healthAsync.when(
            data: (health) => Column(
              children: [
                _buildHealthIndicator('API', health.apiStatus),
                _buildHealthIndicator('Database', health.dbStatus),
                _buildHealthIndicator('Redis Cache', health.cacheStatus),
                _buildHealthIndicator('CI/CD', health.buildStatus),
                const SizedBox(height: 16),
                _buildMetricChart(health.errorRate),
              ],
            ),
            loading: () => MystiqueLoadingIndicator(),
            error: (e, s) => MystiqueAlert(
              message: 'Health check failed',
              type: MystiqueAlertType.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(String label, HealthStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status == HealthStatus.healthy
                  ? DarkMystiqueTheme.successGlow
                  : DarkMystiqueTheme.errorPulse,
              boxShadow: [
                BoxShadow(
                  color: status == HealthStatus.healthy
                      ? DarkMystiqueTheme.successGlow.withOpacity(0.5)
                      : DarkMystiqueTheme.errorPulse.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: status == HealthStatus.healthy
                  ? DarkMystiqueTheme.successGlow
                  : DarkMystiqueTheme.errorPulse,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔌 API Integration

### Endpoints to Implement
```dart
// lib/services/api_service.dart
class ApiService {
  final Dio _dio;

  // Agent endpoints
  Future<List<AgentStatus>> getAgentStatus() =>
      _dio.get('/agents/status');

  Future<AgentDetails> getAgentDetails(String agentId) =>
      _dio.get('/agents/$agentId/details');

  Future<List<ActivityLog>> getAgentLogs(String agentId) =>
      _dio.get('/agents/$agentId/logs');

  // Project metrics
  Future<ProjectMetrics> getProjectMetrics() =>
      _dio.get('/project/metrics');

  Future<SprintDetails> getCurrentSprint() =>
      _dio.get('/project/sprint/current');

  // System health
  Future<SystemHealth> getSystemHealth() =>
      _dio.get('/system/health');
}
```

### WebSocket Events
```javascript
// Expected WebSocket message format
{
  "type": "agent_update",
  "data": {
    "agentId": "solution-architect",
    "status": "active",
    "emotion": "happy",
    "currentTask": "Reviewing API design",
    "progress": 0.75
  }
}

{
  "type": "activity_log",
  "data": {
    "timestamp": "2024-12-20T14:30:00Z",
    "agent": "backend-engineer",
    "action": "completed",
    "message": "Implemented user authentication endpoint"
  }
}
```

## 🧪 Testing Requirements

### Unit Tests
```dart
// test/providers/agent_provider_test.dart
void main() {
  group('AgentStatusProvider', () {
    test('should fetch agent status on init', () async {
      // Test implementation
    });

    test('should fall back to polling on WebSocket error', () async {
      // Test implementation
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/agent_card_test.dart
void main() {
  testWidgets('AgentCard shows correct status', (tester) async {
    // Test implementation
  });
}
```

### Integration Tests
```dart
// integration_test/project_board_test.dart
void main() {
  testWidgets('Project board loads and updates', (tester) async {
    // Test implementation
  });
}
```

## 📈 Performance Targets

- **Initial Load**: < 2 seconds
- **WebSocket Latency**: < 100ms
- **UI Update**: 60 FPS
- **Memory Usage**: < 150MB
- **CPU Usage**: < 30% idle

## 🎨 Design Assets

- Figma file: [Link to design]
- Icons: Material Icons + Custom SVGs
- Animations: Lottie files for celebrations

## 📝 Definition of Done

- [ ] All components implemented and styled
- [ ] WebSocket real-time updates working
- [ ] Polling fallback implemented
- [ ] Responsive design for all screen sizes
- [ ] Unit tests > 80% coverage
- [ ] Widget tests for all components
- [ ] Integration tests passing
- [ ] Performance targets met
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Deployed to staging

## 🚀 Deployment

### Build Commands
```bash
# Development
flutter run -d chrome --web-port=3000

# Production build
flutter build web --release --web-renderer=canvaskit

# Docker deployment
docker build -f Dockerfile.dashboard -t chain-dashboard .
docker run -p 3000:80 chain-dashboard
```

### Environment Variables
```env
API_BASE_URL=http://localhost:8080/api/v1
WS_URL=ws://localhost:8080/api/v1/ws
POLLING_INTERVAL=5000
```

## 📚 Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Riverpod Documentation](https://riverpod.dev/)
- [WebSocket Channel Package](https://pub.dev/packages/web_socket_channel)
- [Project Board Design Spec](../designs/project-board-specification.md)
- [Mystique Components](../../frontend/shared/lib/widgets/mystique_components.dart)

## 💬 Questions?

Contact: Technical Project Manager
Slack: #frontend-development
Design Reviews: Every Tuesday 2 PM

---

**Note**: Start with Phase 1 and 2 to get the foundation ready. The UI mockups from the designer can be integrated as they become available. Focus on getting real-time data flow working early to identify any backend API gaps.