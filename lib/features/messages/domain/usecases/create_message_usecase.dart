import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

class CreateMessageUsecase implements UsecaseWithParams<MessageEntity, String> {
  final IMessageRepository _repository;

  CreateMessageUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MessageEntity>> call(String content) {
    return _repository.createMessage(content);
  }
}
