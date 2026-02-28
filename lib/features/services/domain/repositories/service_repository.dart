import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';

abstract interface class IServiceRepository {
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page,
    int limit,
  });

  Future<Either<Failure, ServiceEntity>> getServiceById(String serviceId);

  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page,
    int limit,
  });
}
