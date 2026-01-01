import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/provider/data/datasource/provider_datasource.dart';
import 'package:petcare/features/provider/data/model/provider_hive_model.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class ProviderRepository implements IProviderRepository {
  final IProviderDatasource _datasource;

  ProviderRepository({required IProviderDatasource datasource})
    : _datasource = datasource;
  @override
  Future<Either<Failure, bool>> createProvider(ProviderEntity entity) async {
    try {
      // entity to model convertion.
      final model = ProviderHiveModel.fromEntity(entity);
      final result = await _datasource.createProvider(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to create Provider'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProvider(String providerId) {
    // TODO: implement deleteProvider
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProviderEntity>>> getAllProviders() async {
    try {
      final model = await _datasource.getAllProviders();
      final entities = ProviderHiveModel.toEntityList(model);
      return Right(entities);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderEntity>> getProviderById(String providerId) {
    // TODO: implement getProviderById
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> updateProvider(ProviderEntity entity) {
    // TODO: implement updateProvider
    throw UnimplementedError();
  }
}
