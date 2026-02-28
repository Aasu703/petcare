import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';

class CreateOrderUsecase
    implements UsecaseWithParams<OrderEntity, OrderEntity> {
  final IShopRepository _repository;

  CreateOrderUsecase({required IShopRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrderEntity>> call(OrderEntity params) {
    return _repository.createOrder(params);
  }
}
