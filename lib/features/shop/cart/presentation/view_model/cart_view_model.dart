import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/shop/cart/presentation/state/cart_state.dart';
import 'package:petcare/features/shop/di/shop_providers.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/presentation/view_model/shop_view_model.dart';

final cartEntityProvider = Provider<CartEntity>(
  (ref) => ref.watch(shopProvider.select((state) => state.cart)),
);

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>(
  (ref) => CartViewModel(ref),
);

class CartViewModel extends StateNotifier<CartState> {
  final Ref _ref;

  CartViewModel(this._ref) : super(const CartState());

  void increaseQuantity(CartItemEntity item) {
    final productId = item.product.productId;
    if (productId == null || productId.isEmpty) return;
    _ref
        .read(shopProvider.notifier)
        .updateQuantity(productId, item.quantity + 1);
  }

  void decreaseQuantity(CartItemEntity item) {
    final productId = item.product.productId;
    if (productId == null || productId.isEmpty) return;

    if (item.quantity > 1) {
      _ref
          .read(shopProvider.notifier)
          .updateQuantity(productId, item.quantity - 1);
      return;
    }
    _ref.read(shopProvider.notifier).removeFromCart(productId);
  }

  void removeItem(CartItemEntity item) {
    final productId = item.product.productId;
    if (productId == null || productId.isEmpty) return;
    _ref.read(shopProvider.notifier).removeFromCart(productId);
  }

  void clearCart() {
    _ref.read(shopProvider.notifier).clearCart();
  }

  Future<bool> checkout() async {
    final cart = _ref.read(shopProvider).cart;
    if (cart.items.isEmpty) {
      state = state.copyWith(errorMessage: 'Your cart is empty');
      return false;
    }

    state = state.copyWith(isCheckingOut: true, clearError: true);

    final order = OrderEntity(
      items: cart.items
          .map(
            (item) => OrderItemEntity(
              productId: item.product.productId ?? '',
              productName: item.product.productName,
              quantity: item.quantity,
              price: item.product.price ?? 0,
            ),
          )
          .toList(),
      totalAmount: cart.totalAmount,
    );

    final createOrderUsecase = _ref.read(createOrderUsecaseProvider);
    final result = await createOrderUsecase(order);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingOut: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        _ref.read(shopProvider.notifier).clearCart();
        state = state.copyWith(isCheckingOut: false);
        return true;
      },
    );
  }
}
