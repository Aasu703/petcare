import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;

  const ResetPasswordParams({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}

class ResetPasswordUsecase
    implements UsecaseWithParams<bool, ResetPasswordParams> {
  final IAuthRepository _repository;

  ResetPasswordUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}
