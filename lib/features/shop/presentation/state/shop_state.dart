import 'package:petcare/features/shop/domain/entities/cart_entity.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';

class ShopState {
  final bool isLoading;
  final String? error;
  final List<ProductEntity> products;
  final CartEntity cart;

  const ShopState({
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.cart = const CartEntity(),
  });

  ShopState copyWith({
    bool? isLoading,
    String? error,
    List<ProductEntity>? products,
    CartEntity? cart,
  }) {
    return ShopState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      cart: cart ?? this.cart,
    );
  }
}
