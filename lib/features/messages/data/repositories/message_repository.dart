import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/data/datasources/remote/message_remote_datasource.dart';
import 'package:petcare/features/messages/data/models/message_model.dart';

abstract interface class IMessageRepository {
  Future<List<MessageModel>> getAllMessages({int page, int limit});
  Future<List<MessageModel>> getMyMessages();
  Future<MessageModel> createMessage(String content);
  Future<MessageModel?> getMessageById(String messageId);
  Future<MessageModel> updateMessage(String messageId, String content);
  Future<bool> deleteMessage(String messageId);
}

final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  return MessageRepository(
    remoteDataSource: ref.read(messageRemoteDatasourceProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class MessageRepository implements IMessageRepository {
  final IMessageRemoteDataSource _remoteDataSource;
  final UserSessionService _sessionService;

  MessageRepository({
    required IMessageRemoteDataSource remoteDataSource,
    required UserSessionService sessionService,
  }) : _remoteDataSource = remoteDataSource,
       _sessionService = sessionService;

  @override
  Future<List<MessageModel>> getAllMessages({
    int page = 1,
    int limit = 20,
  }) async {
    return await _remoteDataSource.getAllMessages(page: page, limit: limit);
  }

  @override
  Future<List<MessageModel>> getMyMessages() async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    return await _remoteDataSource.getMyMessages();
  }

  @override
  Future<MessageModel> createMessage(String content) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    return await _remoteDataSource.createMessage(content);
  }

  @override
  Future<MessageModel?> getMessageById(String messageId) async {
    return await _remoteDataSource.getMessageById(messageId);
  }

  @override
  Future<MessageModel> updateMessage(String messageId, String content) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    return await _remoteDataSource.updateMessage(messageId, content);
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    return await _remoteDataSource.deleteMessage(messageId);
  }
}
