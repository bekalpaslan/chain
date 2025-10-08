import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_chain/core/services/api_client.dart';
import 'package:the_chain/core/services/auth_service.dart';
import 'package:the_chain/core/services/chain_service.dart';
import 'package:the_chain/core/services/ticket_service.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final ticketServiceProvider = Provider<TicketService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TicketService(apiClient);
});

final chainServiceProvider = Provider<ChainService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChainService(apiClient);
});
