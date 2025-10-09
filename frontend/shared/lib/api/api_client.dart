import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/chain_stats.dart';
import '../models/ticket.dart';
import '../models/user.dart';
import '../models/user_chain_response.dart';
import '../utils/storage_helper.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConstants.defaultBaseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: this.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await StorageHelper.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';

          // Add user ID header if available
          final userId = await StorageHelper.getUserId();
          if (userId != null) {
            options.headers['X-User-Id'] = userId;
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - token expired
        if (error.response?.statusCode == 401) {
          try {
            // Try to refresh token
            final savedRefreshToken = await StorageHelper.getRefreshToken();
            if (savedRefreshToken != null) {
              final newTokens = await refreshToken(savedRefreshToken);
              await StorageHelper.saveAccessToken(newTokens.tokens.accessToken);
              await StorageHelper.saveRefreshToken(newTokens.tokens.refreshToken);

              // Retry the original request
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer ${newTokens.tokens.accessToken}';
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            }
          } catch (e) {
            // Refresh failed, clear auth and propagate error
            await StorageHelper.clearAuthData();
          }
        }
        handler.next(error);
      },
    ));
  }

  // ========== Public endpoints (no auth required) ==========

  /// Get chain statistics
  Future<ChainStats> getChainStats() async {
    try {
      final response = await _dio.get(ApiConstants.chainStats);
      return ChainStats.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Health check
  Future<String> getHealth() async {
    try {
      final response = await _dio.get(ApiConstants.authHealth);
      return response.data.toString();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Auth endpoints ==========

  /// Login with device credentials
  Future<AuthResponse> login(String deviceId, String deviceFingerprint) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: {
          'deviceId': deviceId,
          'deviceFingerprint': deviceFingerprint,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Register with invitation ticket
  Future<AuthResponse> register({
    required String ticketId,
    required String ticketSignature,
    required String displayName,
    required String deviceId,
    required String deviceFingerprint,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRegister,
        data: {
          'ticketId': ticketId,
          'ticketSignature': ticketSignature,
          'displayName': displayName,
          'deviceId': deviceId,
          'deviceFingerprint': deviceFingerprint,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRefresh,
        data: {
          'refreshToken': refreshToken,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== User endpoints (auth required) ==========

  /// Get current user profile
  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.usersMe);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's chain (children)
  Future<List<UserChainResponse>> getUserChain() async {
    try {
      final response = await _dio.get(ApiConstants.usersMeChain);
      return (response.data as List)
          .map((json) => UserChainResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Ticket endpoints (auth required) ==========

  /// Generate a new invitation ticket
  Future<Ticket> generateTicket() async {
    try {
      final response = await _dio.post(ApiConstants.ticketsGenerate);
      return Ticket.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get ticket details by ID
  Future<Ticket> getTicketById(String ticketId) async {
    try {
      final response = await _dio.get('${ApiConstants.ticketsById}/$ticketId');
      return Ticket.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ========== Error handling ==========

  ApiException _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        final message = data is Map ? (data['message'] ?? data['error']) : error.message;
        return ApiException(
          message: message?.toString() ?? 'Unknown error',
          statusCode: error.response!.statusCode,
        );
      } else {
        return ApiException(
          message: error.message ?? 'Network error',
          statusCode: null,
        );
      }
    }
    return ApiException(message: error.toString(), statusCode: null);
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
