import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase
    implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _repository;

  LoginUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    print('⚡ USECASE LOGIN: Starting login usecase for email: ${params.email}');

    final result = _repository.login(params.email, params.password);

    result.then((either) {
      either.fold(
        (failure) {
          print(
            '❌ USECASE LOGIN: Login failed with message: ${failure.message}',
          );
        },
        (user) {
          print('✅ USECASE LOGIN: Login successful for user: ${user.email}');
        },
      );
    });

    return result;
  }
}
