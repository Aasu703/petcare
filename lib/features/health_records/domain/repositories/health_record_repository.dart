import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';

abstract interface class IHealthRecordRepository {
  Future<Either<Failure, List<HealthRecordEntity>>> getByPetId(String petId);
  Future<Either<Failure, HealthRecordEntity>> createRecord(
    HealthRecordEntity record,
  );
  Future<Either<Failure, HealthRecordEntity>> updateRecord(
    String recordId,
    HealthRecordEntity record,
  );
  Future<Either<Failure, bool>> deleteRecord(String recordId);
}
