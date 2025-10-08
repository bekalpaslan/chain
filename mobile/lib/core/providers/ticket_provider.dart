import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_chain/core/models/ticket_model.dart';
import 'package:the_chain/core/providers/service_providers.dart';
import 'package:the_chain/core/services/ticket_service.dart';

// Ticket state
class TicketState {
  final TicketModel? currentTicket;
  final List<TicketModel> tickets;
  final bool isLoading;
  final String? error;

  TicketState({
    this.currentTicket,
    this.tickets = const [],
    this.isLoading = false,
    this.error,
  });

  TicketState copyWith({
    TicketModel? currentTicket,
    List<TicketModel>? tickets,
    bool? isLoading,
    String? error,
  }) {
    return TicketState(
      currentTicket: currentTicket ?? this.currentTicket,
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Ticket state notifier
class TicketNotifier extends StateNotifier<TicketState> {
  final TicketService _ticketService;

  TicketNotifier(this._ticketService) : super(TicketState());

  Future<void> generateTicket() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ticket = await _ticketService.generateTicket();
      state = state.copyWith(
        currentTicket: ticket,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> scanTicket({
    required String ticketCode,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _ticketService.scanTicket(
        ticketCode: ticketCode,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> loadMyTickets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tickets = await _ticketService.getMyTickets();
      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Ticket provider
final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  final ticketService = ref.watch(ticketServiceProvider);
  return TicketNotifier(ticketService);
});
