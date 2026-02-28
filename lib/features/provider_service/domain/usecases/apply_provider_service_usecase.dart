import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/domain/repositories/provider_service_repository.dart';

class ApplyProviderServiceParams extends Equatable {
  final ProviderServiceEntity entity;
  final String? medicalLicensePath;
  final String? certificationPath;
  final List<String> facilityImagePaths;
  final String? businessRegistrationPath;

  const ApplyProviderServiceParams({
    required this.entity,
    this.medicalLicensePath,
    this.certificationPath,
    this.facilityImagePaths = const [],
    this.businessRegistrationPath,
  });

  @override
  List<Object?> get props => [
    entity,
    medicalLicensePath,
    certificationPath,
    facilityImagePaths,
    businessRegistrationPath,
  ];
}

class ApplyProviderServiceUsecase
    implements
        UsecaseWithParams<ProviderServiceEntity, ApplyProviderServiceParams> {
  final IProviderServiceRepository _repository;

  ApplyProviderServiceUsecase({required IProviderServiceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, ProviderServiceEntity>> call(
    ApplyProviderServiceParams params,
  ) {
    return _repository.applyForService(
      params.entity,
      medicalLicensePath: params.medicalLicensePath,
      certificationPath: params.certificationPath,
      facilityImagePaths: params.facilityImagePaths,
      businessRegistrationPath: params.businessRegistrationPath,
    );
  }
}
