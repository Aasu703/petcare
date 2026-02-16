import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/messages/data/datasources/remote/message_remote_datasource.dart';
import 'package:petcare/features/messages/data/mappers/message_mapper.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

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
  Future<Either<Failure, List<MessageEntity>>> getAllMessages({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final messages = await _remoteDataSource.getAllMessages(
        page: page,
        limit: limit,
      );
      return Right(MessageMapper.toEntityList(messages));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMyMessages() async {
    try {
      if (!_sessionService.isLoggedIn()) {
        return Left(ServerFailure(message: 'User not authenticated'));
      }
      final messages = await _remoteDataSource.getMyMessages();
      return Right(MessageMapper.toEntityList(messages));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> createMessage(String content) async {
    try {
      if (!_sessionService.isLoggedIn()) {
        return Left(ServerFailure(message: 'User not authenticated'));
      }
      final message = await _remoteDataSource.createMessage(content);
      return Right(MessageMapper.toEntity(message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> getMessageById(
    String messageId,
  ) async {
    try {
      final message = await _remoteDataSource.getMessageById(messageId);
      if (message == null) {
        return Left(ServerFailure(message: 'Message not found'));
      }
      return Right(MessageMapper.toEntity(message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> updateMessage(
    String messageId,
    String content,
  ) async {
    try {
      if (!_sessionService.isLoggedIn()) {
        return Left(ServerFailure(message: 'User not authenticated'));
      }
      final message = await _remoteDataSource.updateMessage(messageId, content);
      return Right(MessageMapper.toEntity(message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMessage(String messageId) async {
    try {
      if (!_sessionService.isLoggedIn()) {
        return Left(ServerFailure(message: 'User not authenticated'));
      }
      final result = await _remoteDataSource.deleteMessage(messageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
