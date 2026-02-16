import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/data/models/message_model.dart';

abstract interface class IMessageRemoteDataSource {
  Future<List<MessageModel>> getAllMessages({int page, int limit});
  Future<List<MessageModel>> getMyMessages();
  Future<MessageModel> createMessage(String content);
  Future<MessageModel?> getMessageById(String messageId);
  Future<MessageModel> updateMessage(String messageId, String content);
  Future<bool> deleteMessage(String messageId);
}

final messageRemoteDatasourceProvider = Provider<IMessageRemoteDataSource>((
  ref,
) {
  return MessageRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class MessageRemoteDataSource implements IMessageRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  MessageRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  @override
  Future<List<MessageModel>> getAllMessages({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.messageList,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? data['messages'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMyMessages() async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.get(ApiEndpoints.messageMy);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageModel> createMessage(String content) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.post(
      ApiEndpoints.messageList,
      data: {'content': content},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final messageData = data['data'] ?? data;
      if (messageData is Map<String, dynamic>) {
        return MessageModel.fromJson(messageData);
      }
    }
    throw Exception('Failed to create message');
  }

  @override
  Future<MessageModel?> getMessageById(String messageId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.messageById}/$messageId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final messageData = data['data'] ?? data;
      if (messageData is Map<String, dynamic>) {
        return MessageModel.fromJson(messageData);
      }
    }
    return null;
  }

  @override
  Future<MessageModel> updateMessage(String messageId, String content) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.put(
      '${ApiEndpoints.messageById}/$messageId',
      data: {'content': content},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final messageData = data['data'] ?? data;
      if (messageData is Map<String, dynamic>) {
        return MessageModel.fromJson(messageData);
      }
    }
    throw Exception('Failed to update message');
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    await _apiClient.delete('${ApiEndpoints.messageById}/$messageId');
    return true;
  }
}
