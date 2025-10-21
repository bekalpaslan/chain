import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/api/api_client.dart';
import '../models/dashboard_models.dart';

/// Main dashboard data provider
final dashboardDataProvider =
    StateNotifierProvider<DashboardDataNotifier, AsyncValue<DashboardData>>(
  (ref) => DashboardDataNotifier(ref),
);

class DashboardDataNotifier extends StateNotifier<AsyncValue<DashboardData>> {
  final Ref ref;
  final ApiClient _apiClient = ApiClient();

  DashboardDataNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> loadDashboardData() async {
    state = const AsyncValue.loading();
    try {
      // Single comprehensive API call
      final dashboardJson = await _apiClient.getDashboard();
      final dashboardData = DashboardData.fromJson(dashboardJson);

      state = AsyncValue.data(dashboardData);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> loadMoreActivities() async {
    // Load additional activities for pagination
    // TODO: Implement actual pagination API endpoint
    if (state.hasValue) {
      // For now, just reload the dashboard
      await loadDashboardData();
    }
  }

  Future<List<ChainMember>> loadMoreChainMembers(int offset, int limit) async {
    try {
      // TODO: Replace with actual paginated API endpoint
      // For now, simulate pagination with existing data
      if (state.hasValue && state.value!.chainMembers.isNotEmpty) {
        // Return empty if we've already loaded all members
        if (offset >= state.value!.chainMembers.length) {
          return [];
        }

        // Return a slice of existing members (simulating pagination)
        final endIndex = (offset + limit).clamp(0, state.value!.chainMembers.length);
        return state.value!.chainMembers.sublist(offset, endIndex);
      }

      // In production, this would be an API call like:
      // final response = await _apiClient.getChainMembers(offset: offset, limit: limit);
      // return response.map((json) => ChainMember.fromJson(json)).toList();

      return [];
    } catch (error) {
      print('Error loading more chain members: $error');
      return [];
    }
  }

  void markNotificationsRead() {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(unreadNotifications: 0),
      );
    }
  }

  void updateActiveTicketStatus(bool hasTicket) {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(hasActiveTicket: hasTicket),
      );
    }
  }
}

/// Provider for real-time updates via WebSocket
final realtimeUpdatesProvider = StreamProvider<RealtimeUpdate>((ref) {
  // TODO: Implement WebSocket connection
  return Stream.periodic(
    const Duration(seconds: 10),
    (count) => RealtimeUpdate(
      type: RealtimeUpdateType.chainGrowth,
      data: {'count': count},
    ),
  );
});

/// Provider for user preferences
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  (ref) => UserPreferencesNotifier(),
);

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier()
      : super(
          UserPreferences(
            enableNotifications: true,
            enableHaptics: true,
            enableAnimations: true,
            compactMode: false,
          ),
        );

  void toggleNotifications() {
    state = state.copyWith(enableNotifications: !state.enableNotifications);
  }

  void toggleHaptics() {
    state = state.copyWith(enableHaptics: !state.enableHaptics);
  }

  void toggleAnimations() {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
  }

  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
  }
}

/// Provider for chain position tracking
final chainPositionProvider = StateProvider<int>((ref) {
  return ref.watch(dashboardDataProvider).valueOrNull?.user.position ?? 0;
});

/// Provider for active ticket countdown
final ticketCountdownProvider = StreamProvider<Duration>((ref) {
  // TODO: Get actual expiry time from API
  final expiryTime = DateTime.now().add(const Duration(hours: 23));

  return Stream.periodic(
    const Duration(seconds: 1),
    (_) => expiryTime.difference(DateTime.now()),
  ).takeWhile((duration) => duration.isNegative == false);
});