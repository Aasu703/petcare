import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/domain/repositories/provider_service_repository.dart';

class GetMyProviderServicesUsecase
    implements UsecaseWithoutParams<List<ProviderServiceEntity>> {
  final IProviderServiceRepository _repository;

  GetMyProviderServicesUsecase({required IProviderServiceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ProviderServiceEntity>>> call() {
    return _repository.getMyServices();
  }
}
