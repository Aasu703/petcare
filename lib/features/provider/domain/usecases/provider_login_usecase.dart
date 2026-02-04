import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class ProviderLoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const ProviderLoginUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class ProviderLoginUsecase
    implements UsecaseWithParams<ProviderEntity, ProviderLoginUsecaseParams> {
  final IProviderRepository _repository;

  ProviderLoginUsecase({required IProviderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProviderEntity>> call(
    ProviderLoginUsecaseParams params,
  ) {
    return _repository.login(params.email, params.password);
  }
}
