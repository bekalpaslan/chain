class ApiConfig {
  // For Android Emulator use 10.0.2.2, for iOS Simulator use localhost
  // For physical devices, use your machine's IP address
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

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
  static const String wsUrl = 'ws://10.0.2.2:8080/api/v1/ws/chain';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
