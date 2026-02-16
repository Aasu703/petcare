import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

class UpdateMessageParams extends Equatable {
  final String messageId;
  final String content;

  const UpdateMessageParams({required this.messageId, required this.content});

  @override
  List<Object?> get props => [messageId, content];
}

class UpdateMessageUsecase
    implements UsecaseWithParams<MessageEntity, UpdateMessageParams> {
  final IMessageRepository _repository;

  UpdateMessageUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, MessageEntity>> call(UpdateMessageParams params) {
    return _repository.updateMessage(params.messageId, params.content);
  }
}
