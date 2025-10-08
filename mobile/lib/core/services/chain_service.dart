import 'package:dio/dio.dart';
import 'package:the_chain/core/config/api_config.dart';
import 'package:the_chain/core/models/chain_stats_model.dart';
import 'package:the_chain/core/models/user_model.dart';
import 'package:the_chain/core/services/api_client.dart';

class ChainService {
  final ApiClient _apiClient;

  ChainService(this._apiClient);

  Future<ChainStatsModel> getChainStats() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.chainStats);
      return ChainStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getMyChainInfo() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.myChainInfo);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
