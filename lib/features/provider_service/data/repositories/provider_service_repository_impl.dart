import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/provider_service/data/datasource/remote/provider_service_remote_datasource.dart';
import 'package:petcare/features/provider_service/data/models/provider_service_model.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/domain/repositories/provider_service_repository.dart';

class ProviderServiceRepositoryImpl implements IProviderServiceRepository {
  final IProviderServiceRemoteDataSource _remoteDataSource;

  ProviderServiceRepositoryImpl({
    required IProviderServiceRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ProviderServiceEntity>> applyForService(
    ProviderServiceEntity entity, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths = const [],
    String? businessRegistrationPath,
  }) async {
    try {
      final model = ProviderServiceModel.fromEntity(entity);
      final result = await _remoteDataSource.applyForService(
        model,
        medicalLicensePath: medicalLicensePath,
        certificationPath: certificationPath,
        facilityImagePaths: facilityImagePaths,
        businessRegistrationPath: businessRegistrationPath,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProviderServiceEntity>>> getMyServices() async {
    try {
      final models = await _remoteDataSource.getMyServices();
      return Right(ProviderServiceModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderServiceEntity>> getServiceById(
    String serviceId,
  ) async {
    try {
      final model = await _remoteDataSource.getServiceById(serviceId);
      if (model == null) {
        return const Left(ServerFailure(message: 'Service not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
