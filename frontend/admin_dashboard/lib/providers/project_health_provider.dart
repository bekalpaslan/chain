import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/project_health.dart';

/// Provider for project health data with auto-refresh capability
class ProjectHealthProvider with ChangeNotifier {
  ProjectHealth? _projectHealth;
  bool _isLoading = false;
  String? _error;
  Timer? _autoRefreshTimer;

  // Configuration
  final Duration _refreshInterval = const Duration(seconds: 60);
  static const String _dataPath = '.claude/data/project_health.json';

  ProjectHealth? get projectHealth => _projectHealth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _projectHealth != null;

  ProjectHealthProvider() {
    _init();
  }

  void _init() {
    loadHealthData();
    _startAutoRefresh();
  }

  /// Load health data from file system or web
  Future<void> loadHealthData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      String jsonString;

      if (kIsWeb) {
        // For web, try to fetch from server or use bundled asset
        try {
          final response = await http.get(Uri.parse('/$_dataPath'));
          if (response.statusCode == 200) {
            jsonString = response.body;
          } else {
            // Fallback to bundled asset
            jsonString = await rootBundle.loadString('assets/data/project_health.json');
          }
        } catch (e) {
          // Fallback to bundled asset
          jsonString = await rootBundle.loadString('assets/data/project_health.json');
        }
      } else {
        // For desktop/mobile, read from file system
        // In production, you might want to use path_provider to get the correct path
        jsonString = await rootBundle.loadString('assets/data/project_health.json');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _projectHealth = ProjectHealth.fromJson(jsonData);
      _error = null;
    } catch (e) {
      _error = 'Failed to load project health data: ${e.toString()}';
      debugPrint(_error);
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      } else if (_error == null) {
        // Only notify if refresh was successful
        notifyListeners();
      }
    }
  }

  /// Start automatic refresh timer
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) {
      loadHealthData(silent: true);
    });
  }

  /// Stop automatic refresh
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Manually refresh data
  Future<void> refresh() async {
    await loadHealthData(silent: false);
  }

  /// Get color for completion score
  Color getScoreColor(double score) {
    if (score >= 7.0) {
      return const Color(0xFF4CAF50); // Green
    } else if (score >= 5.0) {
      return const Color(0xFFFFC107); // Yellow/Amber
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  /// Get status label from score
  String getStatusLabel(double score) {
    if (score >= 7.0) return 'Good';
    if (score >= 5.0) return 'Fair';
    return 'Critical';
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
