import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final auth = ref.watch(authProvider);
  return ApiService(token: auth.token);
});

class ApiService {
  final Dio _dio;
  final String? token;

  ApiService({this.token}) : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // Scenarios
  Future<List<dynamic>> getScenarios() async {
    final res = await _dio.get(AppConstants.scenarioEndpoint);
    return (res.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createScenario(Map<String, dynamic> data) async {
    final res = await _dio.post(AppConstants.scenarioEndpoint, data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateScenario(String id, Map<String, dynamic> data) async {
    await _dio.put('${AppConstants.scenarioEndpoint}?id=$id', data: data);
  }

  Future<void> deleteScenario(String id) async {
    await _dio.delete('${AppConstants.scenarioEndpoint}?id=$id');
  }

  // Conversations
  Future<List<dynamic>> getConversations() async {
    final res = await _dio.get(AppConstants.conversationEndpoint);
    return (res.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> getConversationDetail(String id) async {
    final res = await _dio.get('${AppConstants.conversationEndpoint}?id=$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createConversation(String scenarioId, String title) async {
    final res = await _dio.post(
      AppConstants.conversationEndpoint,
      data: {'scenario_id': scenarioId, 'session_title': title},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete('${AppConstants.conversationEndpoint}?id=$id');
  }

  // AI Chat
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String message,
    required String category,
    required String scenarioContext,
    required List<Map<String, dynamic>> messageHistory,
  }) async {
    final res = await _dio.post(
      AppConstants.aiChatEndpoint,
      data: {
        'conversation_id': conversationId,
        'message': message,
        'category': category,
        'scenario_context': scenarioContext,
        'message_history': messageHistory,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // Analysis
  Future<Map<String, dynamic>> analyzeConversation(String conversationId) async {
    final res = await _dio.post(
      AppConstants.analysisEndpoint,
      data: {'conversation_id': conversationId},
    );
    return res.data['data'] as Map<String, dynamic>;
  }
}
