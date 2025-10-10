import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/agent_status.dart';

class DashboardProvider extends ChangeNotifier {
  List<AgentStatus> _agents = [];
  ProjectStatus? _projectStatus;
  List<String> _activityLogs = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  DateTime _lastUpdate = DateTime.now();

  // Getters
  List<AgentStatus> get agents => _agents;
  ProjectStatus? get projectStatus => _projectStatus;
  List<String> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get lastUpdate => _lastUpdate;

  // Filtered agent lists
  List<AgentStatus> get activeAgents =>
      _agents.where((a) => a.status == 'active' || a.status == 'working').toList();

  List<AgentStatus> get blockedAgents =>
      _agents.where((a) => a.status == 'blocked').toList();

  List<AgentStatus> get idleAgents =>
      _agents.where((a) => a.status == 'idle').toList();

  DashboardProvider() {
    loadData();
    startPolling();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For web, we'll try to read from a local endpoint
      // In production, this would be your actual API
      if (kIsWeb) {
        await _loadFromLocalFile();
      } else {
        await _loadFromFileSystem();
      }

      _lastUpdate = DateTime.now();
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
      // Use mock data as fallback
      _loadMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromLocalFile() async {
    try {
      // Try to fetch from a local server endpoint
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/status'),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _parseStatusData(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      _loadMockData();
    }
  }

  Future<void> _loadFromFileSystem() async {
    try {
      // Read from actual file system (for desktop/mobile)
      final statusFile = File('../../.claude/status.json');
      if (await statusFile.exists()) {
        final content = await statusFile.readAsString();
        final data = json.decode(content);
        _parseStatusData(data);
      } else {
        _loadMockData();
      }
    } catch (e) {
      _loadMockData();
    }
  }

  void _parseStatusData(Map<String, dynamic> data) {
    // Parse project status
    if (data.containsKey('project_status')) {
      _projectStatus = ProjectStatus.fromJson(data);
    }

    // Parse agents
    if (data.containsKey('agents')) {
      final agentsMap = data['agents'] as Map<String, dynamic>;
      _agents = agentsMap.entries
          .map((entry) => AgentStatus.fromJson(entry.key, entry.value))
          .toList();

      // Sort by status priority: active/working > blocked > idle
      _agents.sort((a, b) {
        final statusOrder = {'active': 0, 'working': 0, 'blocked': 1, 'idle': 2};
        final aOrder = statusOrder[a.status] ?? 3;
        final bOrder = statusOrder[b.status] ?? 3;
        return aOrder.compareTo(bOrder);
      });
    }

    // Generate some activity logs
    _generateActivityLogs();
  }

  void _loadMockData() {
    _projectStatus = ProjectStatus(
      health: 'healthy',
      activeSprint: 'Frontend Foundation & Testing Excellence',
      sprintId: 'SPRINT-2025-01',
      sprintProgress: 10,
      activeTasks: 8,
      criticalTasks: 2,
      highPriorityTasks: 4,
      totalStoryPoints: 32,
      completedPoints: 3,
      lastUpdated: DateTime.now(),
    );

    _agents = [
      AgentStatus(
        id: 'senior-frontend-engineer',
        name: 'Senior Frontend Engineer',
        role: 'Frontend Development',
        status: 'active',
        emotion: 'happy',
        currentTask: 'Implementing Project Board Dashboard',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 2)),
        progress: 0.45,
      ),
      AgentStatus(
        id: 'senior-backend-engineer',
        name: 'Senior Backend Engineer',
        role: 'Backend Development',
        status: 'working',
        emotion: 'satisfied',
        currentTask: 'Optimizing ticket chain API endpoints',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
        progress: 0.78,
      ),
      AgentStatus(
        id: 'lead-qa-engineer',
        name: 'Lead QA Engineer',
        role: 'Quality Assurance',
        status: 'blocked',
        emotion: 'frustrated',
        currentTask: 'Test suite failing on CI pipeline',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
        progress: 0.20,
      ),
      AgentStatus(
        id: 'solution-architect',
        name: 'Solution Architect',
        role: 'System Architecture',
        status: 'idle',
        emotion: 'neutral',
        currentTask: null,
        lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AgentStatus(
        id: 'devops-lead',
        name: 'DevOps Lead',
        role: 'DevOps & Infrastructure',
        status: 'active',
        emotion: 'satisfied',
        currentTask: 'Setting up Kubernetes cluster',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 8)),
        progress: 0.60,
      ),
      AgentStatus(
        id: 'senior-ui-ux-designer',
        name: 'Senior UI UX Designer',
        role: 'UI/UX Design',
        status: 'idle',
        emotion: 'happy',
        currentTask: null,
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AgentStatus(
        id: 'principal-database-architect',
        name: 'Principal Database Architect',
        role: 'Database Design',
        status: 'idle',
        emotion: 'neutral',
        currentTask: null,
        lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AgentStatus(
        id: 'technical-project-manager',
        name: 'Technical Project Manager',
        role: 'Project Management',
        status: 'active',
        emotion: 'neutral',
        currentTask: 'Sprint planning and backlog grooming',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 10)),
        progress: 0.30,
      ),
    ];

    _generateActivityLogs();
  }

  void _generateActivityLogs() {
    final now = DateTime.now();
    _activityLogs = [
      '[${_formatTime(now)}] Senior Frontend Engineer started working on dashboard implementation',
      '[${_formatTime(now.subtract(const Duration(minutes: 2)))}] DevOps Lead deployed new Docker image to staging',
      '[${_formatTime(now.subtract(const Duration(minutes: 5)))}] Backend Engineer completed API optimization',
      '[${_formatTime(now.subtract(const Duration(minutes: 8)))}] QA Engineer reported test failures in CI/CD pipeline',
      '[${_formatTime(now.subtract(const Duration(minutes: 12)))}] Solution Architect reviewed system design documents',
      '[${_formatTime(now.subtract(const Duration(minutes: 15)))}] Project Manager updated sprint backlog',
      '[${_formatTime(now.subtract(const Duration(minutes: 20)))}] Database Architect optimized query performance',
      '[${_formatTime(now.subtract(const Duration(minutes: 25)))}] UI/UX Designer completed mockups for new feature',
      '[${_formatTime(now.subtract(const Duration(minutes: 30)))}] Frontend Engineer resolved merge conflicts',
      '[${_formatTime(now.subtract(const Duration(minutes: 35)))}] Backend Engineer created new API endpoints',
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      loadData();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}