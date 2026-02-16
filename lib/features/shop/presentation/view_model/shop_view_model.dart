import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/shop/di/shop_providers.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/presentation/state/shop_state.dart';

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref _ref;

  ShopNotifier(this._ref) : super(const ShopState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getProductsUsecaseProvider);
    final result = await usecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) =>
          state = state.copyWith(isLoading: false, products: products),
    );
  }

  Future<void> loadProviderInventory(String providerId) async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = _ref.read(shopRepositoryProvider);
    final result = await repository.getProviderInventory(providerId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (products) =>
          state = state.copyWith(isLoading: false, products: products),
    );
  }

  void addToCart(ProductEntity product) {
    final items = List<CartItemEntity>.from(state.cart.items);
    final index = items.indexWhere(
      (item) => item.product.productId == product.productId,
    );
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItemEntity(product: product));
    }
    state = state.copyWith(cart: CartEntity(items: items));
  }

  void removeFromCart(String productId) {
    final items = state.cart.items
        .where((item) => item.product.productId != productId)
        .toList();
    state = state.copyWith(cart: CartEntity(items: items));
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final items = state.cart.items.map((item) {
      if (item.product.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    state = state.copyWith(cart: CartEntity(items: items));
  }

  void clearCart() {
    state = state.copyWith(cart: const CartEntity());
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});
