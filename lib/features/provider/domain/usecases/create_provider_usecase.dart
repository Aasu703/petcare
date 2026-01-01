// Params

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';

class CreateProviderUsecaseParams extends Equatable {
  final String providerName;

  CreateProviderUsecaseParams({required this.providerName});

  @override
  // TODO: implement props
  List<Object?> get props => [providerName];
}

// Usecase

class CreateProviderUsecase
    implements UsecaseWithParams<bool, CreateProviderUsecaseParams> {
  @override
  Future<Either<Failure, bool>> createProvider(
    CreateProviderUsecaseParams params,
  ) {
    // create provider
    ProviderEntity providerEntity = ProviderEntity(
      business_Name: params.providerName,
    );

    // TODO: use repository to create the provider and return Either<Failure, bool>
    throw UnimplementedError(); // or return something valid
  }
}
