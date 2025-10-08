import 'package:dio/dio.dart';
import 'package:the_chain/core/config/api_config.dart';
import 'package:the_chain/core/models/ticket_model.dart';
import 'package:the_chain/core/services/api_client.dart';

class TicketService {
  final ApiClient _apiClient;

  TicketService(this._apiClient);

  Future<TicketModel> generateTicket() async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.generateTicket);
      return TicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> scanTicket({
    required String ticketCode,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.scanTicket,
        data: {
          'ticketCode': ticketCode,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TicketModel>> getMyTickets() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.myTickets);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => TicketModel.fromJson(json as Map<String, dynamic>)).toList();
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
