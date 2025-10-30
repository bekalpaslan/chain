import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/api/api_client.dart';
import '../models/ticket_models.dart';
import 'dashboard_providers.dart';

/// Provider for the user's active ticket
final activeTicketProvider =
    StateNotifierProvider<ActiveTicketNotifier, AsyncValue<Ticket?>>(
  (ref) => ActiveTicketNotifier(ref),
);

class ActiveTicketNotifier extends StateNotifier<AsyncValue<Ticket?>> {
  final Ref ref;
  final ApiClient _apiClient = ApiClient();

  ActiveTicketNotifier(this.ref) : super(const AsyncValue.loading());

  /// Fetch the user's active ticket
  Future<void> fetchActiveTicket() async {
    state = const AsyncValue.loading();
    try {
      final ticketResponse = await _apiClient.getMyActiveTicket();

      // Convert from shared model to local model with enums
      final ticket = Ticket(
        ticketId: ticketResponse.ticketId,
        qrPayload: ticketResponse.qrPayload,
        qrCodeUrl: ticketResponse.qrCodeUrl,
        deepLink: ticketResponse.deepLink,
        signature: ticketResponse.signature,
        issuedAt: ticketResponse.issuedAt,
        expiresAt: ticketResponse.expiresAt,
        status: _parseTicketStatus(ticketResponse.status),
        timeRemainingMs: ticketResponse.timeRemaining,
        ownerId: ticketResponse.ownerId,
      );

      state = AsyncValue.data(ticket);
    } catch (error, stack) {
      // 404 means no active ticket (user has succeeded)
      if (error is ApiException && error.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(error, stack);
      }
    }
  }

  /// Manually refresh ticket (for retry after network error)
  Future<void> refreshTicket() async {
    await fetchActiveTicket();
  }

  /// Clear ticket (after successful invite)
  void clearTicket() {
    state = const AsyncValue.data(null);
  }

  TicketStatus _parseTicketStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return TicketStatus.active;
      case 'USED':
        return TicketStatus.used;
      case 'EXPIRED':
        return TicketStatus.expired;
      default:
        return TicketStatus.expired;
    }
  }
}

/// Provider for real-time ticket countdown
/// Updates every second to show precise remaining time
final ticketCountdownProvider = StreamProvider.family<Duration, Ticket>(
  (ref, ticket) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) {
        final now = DateTime.now();
        final remaining = ticket.expiresAt.difference(now);
        return remaining.isNegative ? Duration.zero : remaining;
      },
    );
  },
);

/// Provider to check if user should see ticket UI
/// Returns false if user has successfully invited someone (activeChildId != null)
final shouldShowTicketUIProvider = Provider<bool>((ref) {
  final dashboardData = ref.watch(dashboardDataProvider);

  // Hide if user has active child (succeeded)
  final hasSucceeded = dashboardData.valueOrNull?.user.activeChildId != null;
  return !hasSucceeded;
});
