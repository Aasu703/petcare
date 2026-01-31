import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/features/provider/data/datasource/provider_datasource.dart';
import 'package:petcare/features/provider/data/model/provider_api_model.dart';
import 'package:petcare/features/provider/data/model/provider_hive_model.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class ProviderRepositoryImpl implements IProviderRepository {
  final IProviderDatasource _localDataSource;
  final IProviderRemoteDataSource _remoteDataSource;
  final INetworkInfo _networkInfo;

  ProviderRepositoryImpl({
    required IProviderDatasource localDataSource,
    required IProviderRemoteDataSource remoteDataSource,
    required INetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createProvider(ProviderEntity entity) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final apiModel = ProviderApiModel.fromEntity(entity);
        await _remoteDataSource.createProvider(apiModel);
        return const Right(true);
      } else {
        // Offline: fallback to local Hive
        final model = ProviderHiveModel.fromEntity(entity);
        final result = await _localDataSource.createProvider(model);
        if (result) {
          return const Right(true);
        }
        return Left(LocalDatabaseFailure(message: 'Failed to create Provider'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProvider(String providerId) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final result = await _remoteDataSource.deleteProvider(providerId);
        if (result) {
          return const Right(true);
        }
        return Left(ServerFailure(message: 'Failed to delete Provider'));
      } else {
        // Offline: fallback to local Hive
        final result = await _localDataSource.deleteProvider(providerId);
        if (result) {
          return const Right(true);
        }
        return Left(LocalDatabaseFailure(message: 'Failed to delete Provider'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProviderEntity>>> getAllProviders() async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final apiModels = await _remoteDataSource.getAllProviders();
        final entities = ProviderApiModel.toEntityList(apiModels);
        return Right(entities);
      } else {
        // Offline: fallback to local Hive
        final models = await _localDataSource.getAllProviders();
        final entities = ProviderHiveModel.toEntityList(models);
        return Right(entities);
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderEntity>> getProviderById(
    String providerId,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final apiModel = await _remoteDataSource.getProviderById(providerId);
        if (apiModel != null) {
          return Right(apiModel.toEntity());
        }
        return Left(ServerFailure(message: 'Provider not found'));
      } else {
        // Offline: fallback to local Hive
        final model = await _localDataSource.getProviderById(providerId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Provider not found'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProvider(ProviderEntity entity) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final apiModel = ProviderApiModel.fromEntity(entity);
        final result = await _remoteDataSource.updateProvider(apiModel);
        if (result) {
          return const Right(true);
        }
        return Left(ServerFailure(message: 'Failed to update Provider'));
      } else {
        // Offline: fallback to local Hive
        final model = ProviderHiveModel.fromEntity(entity);
        final result = await _localDataSource.updateProvider(model);
        if (result) {
          return const Right(true);
        }
        return Left(LocalDatabaseFailure(message: 'Failed to update Provider'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
