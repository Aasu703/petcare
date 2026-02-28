import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';

abstract interface class IProviderServiceRepository {
  Future<Either<Failure, ProviderServiceEntity>> applyForService(
    ProviderServiceEntity entity, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths,
    String? businessRegistrationPath,
  });

  Future<Either<Failure, List<ProviderServiceEntity>>> getMyServices();

  Future<Either<Failure, ProviderServiceEntity>> getServiceById(
    String serviceId,
  );
}
