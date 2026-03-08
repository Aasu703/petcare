import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUsecase implements UsecaseWithParams<bool, String> {
  final IAuthRepository _repository;

  RequestPasswordResetUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String params) {
    return _repository.requestPasswordReset(params);
  }
}
