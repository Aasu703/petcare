import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _repository;

  GetCurrentUserUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _repository.getCurrentUser();
  }
}
