import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class RegisterUsecaseParams extends Equatable {
  final String email;
  final String firstName;
  final String lastName;
  final String password;

  const RegisterUsecaseParams({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, firstName, lastName, password];
}

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _repository;

  RegisterUsecase({required IAuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      userId: const Uuid().v4(),
      email: params.email,
      FirstName: params.firstName,
      LastName: params.lastName,
      phoneNumber: '',
      username: params.email.split('@').first,
      password: params.password,
      avatar: null,
    );

    return _repository.register(entity);
  }
}
