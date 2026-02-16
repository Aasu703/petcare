import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/features/services/data/datasource/local/service_cache_datasource.dart';
import 'package:petcare/features/services/data/datasource/remote/service_remote_datasource.dart';
import 'package:petcare/features/services/data/models/service_model.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements IServiceRepository {
  final INetworkInfo _networkInfo;
  final IServiceRemoteDataSource _remoteDataSource;
  final IServiceCacheDataSource _cacheDataSource;

  ServiceRepositoryImpl({
    required INetworkInfo networkInfo,
    required IServiceRemoteDataSource remoteDataSource,
    required IServiceCacheDataSource cacheDataSource,
  }) : _networkInfo = networkInfo,
       _remoteDataSource = remoteDataSource,
       _cacheDataSource = cacheDataSource;

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    int page = 1,
    int limit = 20,
  }) async {
    final isConnected = await _networkInfo.isConnected;

    try {
      if (!isConnected) {
        final cached = await _cacheDataSource.getCachedServices();
        if (cached.isEmpty) {
          return const Left(
            NetworkFailure(message: 'No internet connection and no cached data'),
          );
        }
        return Right(ServiceModel.toEntityList(cached));
      }

      final models = await _remoteDataSource.getServices(
        page: page,
        limit: limit,
      );

      // Cache only the first page snapshot for offline explore.
      if (page == 1) {
        await _cacheDataSource.saveServices(models);
      }

      return Right(ServiceModel.toEntityList(models));
    } catch (e) {
      final cached = await _cacheDataSource.getCachedServices();
      if (cached.isNotEmpty) {
        return Right(ServiceModel.toEntityList(cached));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> getServiceById(
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

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByProvider(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getServicesByProvider(
        providerId,
        page: page,
        limit: limit,
      );
      return Right(ServiceModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
