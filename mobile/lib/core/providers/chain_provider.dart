import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_chain/core/models/chain_stats_model.dart';
import 'package:the_chain/core/models/user_model.dart';
import 'package:the_chain/core/providers/service_providers.dart';
import 'package:the_chain/core/services/chain_service.dart';

// Chain stats state
class ChainStatsState {
  final ChainStatsModel? stats;
  final UserModel? myChainInfo;
  final bool isLoading;
  final String? error;

  ChainStatsState({
    this.stats,
    this.myChainInfo,
    this.isLoading = false,
    this.error,
  });

  ChainStatsState copyWith({
    ChainStatsModel? stats,
    UserModel? myChainInfo,
    bool? isLoading,
    String? error,
  }) {
    return ChainStatsState(
      stats: stats ?? this.stats,
      myChainInfo: myChainInfo ?? this.myChainInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Chain stats notifier
class ChainStatsNotifier extends StateNotifier<ChainStatsState> {
  final ChainService _chainService;

  ChainStatsNotifier(this._chainService) : super(ChainStatsState());

  Future<void> loadChainStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _chainService.getChainStats();
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMyChainInfo() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final info = await _chainService.getMyChainInfo();
      state = state.copyWith(
        myChainInfo: info,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadChainStats(),
      loadMyChainInfo(),
    ]);
  }
}

// Chain stats provider
final chainStatsProvider = StateNotifierProvider<ChainStatsNotifier, ChainStatsState>((ref) {
  final chainService = ref.watch(chainServiceProvider);
  return ChainStatsNotifier(chainService);
});
