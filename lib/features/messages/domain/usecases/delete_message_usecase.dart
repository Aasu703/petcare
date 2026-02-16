import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

class DeleteMessageUsecase implements UsecaseWithParams<bool, String> {
  final IMessageRepository _repository;

  DeleteMessageUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String messageId) {
    return _repository.deleteMessage(messageId);
  }
}
