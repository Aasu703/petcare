import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/health_records/data/datasource/remote/health_record_remote_datasource.dart';
import 'package:petcare/features/health_records/data/models/health_record_model.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';
import 'package:petcare/features/health_records/domain/repositories/health_record_repository.dart';

class HealthRecordRepositoryImpl implements IHealthRecordRepository {
  final IHealthRecordRemoteDataSource _remoteDataSource;

  HealthRecordRepositoryImpl({
    required IHealthRecordRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<HealthRecordEntity>>> getByPetId(
    String petId,
  ) async {
    try {
      final models = await _remoteDataSource.getByPetId(petId);
      return Right(HealthRecordModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthRecordEntity>> createRecord(
    HealthRecordEntity record,
  ) async {
    try {
      final model = HealthRecordModel.fromEntity(record);
      final result = await _remoteDataSource.createRecord(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HealthRecordEntity>> updateRecord(
    String recordId,
    HealthRecordEntity record,
  ) async {
    try {
      final model = HealthRecordModel.fromEntity(record);
      final result = await _remoteDataSource.updateRecord(recordId, model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRecord(String recordId) async {
    try {
      final result = await _remoteDataSource.deleteRecord(recordId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
