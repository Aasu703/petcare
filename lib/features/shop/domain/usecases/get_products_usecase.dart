import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';

class GetProductsUsecase implements UsecaseWithoutParams<List<ProductEntity>> {
  final IShopRepository _repository;

  GetProductsUsecase({required IShopRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<ProductEntity>>> call() {
    return _repository.getProducts();
  }
}
