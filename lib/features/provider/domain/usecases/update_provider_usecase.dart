import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';

class UpdateProviderUsecase implements UsecaseWithParams<bool, ProviderEntity> {
  final IProviderRepository _repository;

  UpdateProviderUsecase({required IProviderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(ProviderEntity entity) {
    return _repository.updateProvider(entity);
  }
}
