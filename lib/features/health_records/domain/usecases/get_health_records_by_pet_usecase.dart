import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';
import 'package:petcare/features/health_records/domain/repositories/health_record_repository.dart';

class GetHealthRecordsByPetParams extends Equatable {
  final String petId;

  const GetHealthRecordsByPetParams({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class GetHealthRecordsByPetUsecase
    implements
        UsecaseWithParams<
          List<HealthRecordEntity>,
          GetHealthRecordsByPetParams
        > {
  final IHealthRecordRepository _repository;

  GetHealthRecordsByPetUsecase({required IHealthRecordRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<HealthRecordEntity>>> call(
    GetHealthRecordsByPetParams params,
  ) {
    return _repository.getByPetId(params.petId);
  }
}
