import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/messages/domain/entities/message_entity.dart';
import 'package:petcare/features/messages/domain/repositories/message_repository.dart';

class GetAllMessagesParams extends Equatable {
  final int page;
  final int limit;

  const GetAllMessagesParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class GetAllMessagesUsecase
    implements UsecaseWithParams<List<MessageEntity>, GetAllMessagesParams> {
  final IMessageRepository _repository;

  GetAllMessagesUsecase({required IMessageRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(
    GetAllMessagesParams params,
  ) {
    return _repository.getAllMessages(page: params.page, limit: params.limit);
  }
}
