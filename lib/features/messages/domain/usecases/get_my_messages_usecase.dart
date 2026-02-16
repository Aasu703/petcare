import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

class GetMyMessagesUsecase
    implements UsecaseWithoutParams<List<MessageEntity>> {
  final IMessageRepository _repository;

  GetMyMessagesUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call() {
    return _repository.getMyMessages();
  }
}
