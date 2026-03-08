import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';

class UpdateProviderOrderStatusParams {
  final String orderId;
  final String status;

  const UpdateProviderOrderStatusParams({
    required this.orderId,
    required this.status,
  });
}

class UpdateProviderOrderStatusUsecase
    implements UsecaseWithParams<OrderEntity, UpdateProviderOrderStatusParams> {
  final IShopRepository _repository;

  UpdateProviderOrderStatusUsecase({required IShopRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrderEntity>> call(
    UpdateProviderOrderStatusParams params,
  ) {
    return _repository.updateProviderOrderStatus(
      orderId: params.orderId,
      status: params.status,
    );
  }
}
