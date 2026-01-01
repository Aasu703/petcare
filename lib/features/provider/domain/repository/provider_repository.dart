import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';

// 100% Dart null safety

abstract interface class IProviderRepository {
  Future<Either<Failure, List<ProviderEntity>>> getAllProviders();
  Future<Either<Failure, ProviderEntity>> getProviderById(String providerId);
  Future<Either<Failure, bool>> createProvider(ProviderEntity entity);
  Future<Either<Failure, bool>> updateProvider(ProviderEntity entity);
  Future<Either<Failure, bool>> deleteProvider(String providerId);
}
