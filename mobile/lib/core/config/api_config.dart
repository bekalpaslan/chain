import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Platform-specific base URL
  // For Web: use localhost
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For physical devices: use your machine's IP address
  static String get baseUrl {
    if (kIsWeb) {
      // For web, use localhost
      return 'http://localhost:8080/api/v1';
    } else {
      // For mobile (Android emulator by default)
      return 'http://10.0.2.2:8080/api/v1';
    }
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Ticket endpoints
  static const String generateTicket = '/tickets/generate';
  static const String scanTicket = '/tickets/scan';
  static const String myTickets = '/tickets/my-tickets';

  // Chain endpoints
  static const String chainStats = '/chain/stats';
  static const String myChainInfo = '/chain/my-info';

  // WebSocket
  static String get wsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8080/api/v1/ws/chain';
    } else {
      return 'ws://10.0.2.2:8080/api/v1/ws/chain';
    }
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
