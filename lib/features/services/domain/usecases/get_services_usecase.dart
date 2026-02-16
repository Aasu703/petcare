import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/domain/repositories/service_repository.dart';

class GetServicesParams extends Equatable {
  final int page;
  final int limit;

  const GetServicesParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class GetServicesUsecase
    implements UsecaseWithParams<List<ServiceEntity>, GetServicesParams> {
  final IServiceRepository _repository;

  GetServicesUsecase({required IServiceRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ServiceEntity>>> call(GetServicesParams params) {
    return _repository.getServices(page: params.page, limit: params.limit);
  }
}
