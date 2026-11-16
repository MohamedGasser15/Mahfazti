import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';

class AiChatResponse {
  final String conversationId;
  final String reply;
  final DateTime timestamp;

  AiChatResponse({
    required this.conversationId,
    required this.reply,
    required this.timestamp,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      conversationId: json['conversationId']?.toString() ?? '',
      reply: json['reply']?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class AiConversationItem {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messagesCount;
  final String? lastMessageSnippet;

  AiConversationItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.updatedAt,
    this.messagesCount = 0,
    this.lastMessageSnippet,
  });

  factory AiConversationItem.fromJson(Map<String, dynamic> json) {
    return AiConversationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      messagesCount: json['messagesCount'] is int
          ? json['messagesCount']
          : int.tryParse(json['messagesCount']?.toString() ?? '0') ?? 0,
      lastMessageSnippet: json['lastMessageSnippet']?.toString(),
    );
  }
}

class AiMessageItem {
  final int id;
  final String conversationId;
  final String role; // "user" or "assistant"
  final String content;
  final DateTime createdAt;

  AiMessageItem({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AiMessageItem.fromJson(Map<String, dynamic> json) {
    return AiMessageItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      conversationId: json['conversationId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isUser => role.toLowerCase() == 'user';
}

class AiFinancialRepository {
  final ApiService _apiService = ApiService();

  bool get _useMock =>
      (AppConstants.useMockBackend || AppConstants.isTestingEnvironment) &&
      !_apiService.hasTestingDio;

  Future<AiChatResponse> sendMessage(
    String message, {
    String? conversationId,
    String language = 'ar',
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return AiChatResponse(
        conversationId:
            conversationId ??
            'mock_conv_${DateTime.now().millisecondsSinceEpoch}',
        reply: 'أنا مستشارك المالي الذكي (وضع التجربة). سؤالك: $message',
        timestamp: DateTime.now(),
      );
    }

    try {
      final body = <String, dynamic>{'message': message, 'language': language};
      if (conversationId != null && conversationId.isNotEmpty) {
        body['conversationId'] = conversationId;
      }

      final response = await _apiService.post(
        ApiEndpoints.aiChat,
        body,
        requiresAuth: true,
      );

      return AiChatResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('AI Chat DioException: ${e.message}');
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to communicate with AI advisor: $e');
    }
  }

  Future<List<AiConversationItem>> getConversations() async {
    if (_useMock) return [];

    try {
      final response = await _apiService.get(
        ApiEndpoints.aiConversations,
        requiresAuth: true,
      );

      final List list = response.data as List;
      return list
          .map((e) => AiConversationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('AI getConversations DioException: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting AI conversations: $e');
      return [];
    }
  }

  Future<List<AiMessageItem>> getMessages(String conversationId) async {
    if (_useMock) return [];

    try {
      final response = await _apiService.get(
        '${ApiEndpoints.aiConversations}/$conversationId/messages',
        requiresAuth: true,
      );

      final List list = response.data as List;
      return list
          .map((e) => AiMessageItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('AI getMessages DioException: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting AI messages: $e');
      return [];
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    if (_useMock) return true;

    try {
      await _apiService.delete(
        '${ApiEndpoints.aiConversations}/$conversationId',
        requiresAuth: true,
      );
      return true;
    } on DioException catch (e) {
      debugPrint('AI deleteConversation DioException: ${e.message}');
      return false;
    } catch (_) {
      return false;
    }
  }
}
