import 'package:dio/dio.dart';
import 'package:the_chain/core/config/api_config.dart';
import 'package:the_chain/core/models/user_model.dart';
import 'package:the_chain/core/services/api_client.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> register({
    required String username,
    String? invitationTicket,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.register,
        data: {
          'username': username,
          'invitationTicket': invitationTicket,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else {
      return 'Network error. Please try again.';
    }
  }
}
