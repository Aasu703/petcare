import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/domain/repositories/provider_service_repository.dart';

class GetProviderServiceByIdParams extends Equatable {
  final String serviceId;

  const GetProviderServiceByIdParams({required this.serviceId});

  @override
  List<Object?> get props => [serviceId];
}

class GetProviderServiceByIdUsecase
    implements
        UsecaseWithParams<ProviderServiceEntity, GetProviderServiceByIdParams> {
  final IProviderServiceRepository _repository;

  GetProviderServiceByIdUsecase({
    required IProviderServiceRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, ProviderServiceEntity>> call(
    GetProviderServiceByIdParams params,
  ) {
    return _repository.getServiceById(params.serviceId);
  }
}
