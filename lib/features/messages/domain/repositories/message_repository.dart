import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';

abstract interface class IMessageRepository {
  Future<Either<Failure, List<MessageEntity>>> getAllMessages({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, List<MessageEntity>>> getMyMessages();
  Future<Either<Failure, MessageEntity>> createMessage(String content);
  Future<Either<Failure, MessageEntity>> getMessageById(String messageId);
  Future<Either<Failure, MessageEntity>> updateMessage(
    String messageId,
    String content,
  );
  Future<Either<Failure, bool>> deleteMessage(String messageId);
}
