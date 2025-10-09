class ApiConstants {
  // Base URL - includes /api/v1 context path
  static const String defaultBaseUrl = 'http://localhost:8080/api/v1';

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authHealth = '/auth/health';

  // User endpoints
  static const String usersMe = '/users/me';
  static const String usersMeChain = '/users/me/chain';

  // Ticket endpoints
  static const String ticketsGenerate = '/tickets/generate';
  static const String ticketsById = '/tickets';

  // Chain endpoints
  static const String chainStats = '/chain/stats';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

class AppConstants {
  static const String appName = 'The Chain';
  static const int ticketExpiryHours = 24;
  static const int maxWastedTickets = 3;

  // Storage keys
  static const String keyAccessToken = 'accessToken';
  static const String keyRefreshToken = 'refreshToken';
  static const String keyUserId = 'userId';
  static const String keyDeviceId = 'deviceId';
}
