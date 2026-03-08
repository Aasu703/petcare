import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';

class GetProviderOrdersUsecase
    implements UsecaseWithoutParams<List<OrderEntity>> {
  final IShopRepository _repository;

  GetProviderOrdersUsecase({required IShopRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call() {
    return _repository.getProviderOrders();
  }
}
