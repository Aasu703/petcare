// Params

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class CreateProviderUsecaseParams extends Equatable {
  final String providerName;

  const CreateProviderUsecaseParams({required this.providerName});

  @override
  // TODO: implement props
  List<Object?> get props => [providerName];
}

// Usecase

class CreateProviderUsecase
    implements UsecaseWithParams<bool, CreateProviderUsecaseParams> {
  final IProviderRepository _repository;

  CreateProviderUsecase({required IProviderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(CreateProviderUsecaseParams params) {
    final providerEntity = ProviderEntity(
      businessName: params.providerName,
      providerId: '',
      userId: '',
      address: '',
      phone: '',
      rating: 0,
    );

    return _repository.createProvider(providerEntity);
  }
}
