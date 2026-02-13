import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/di/shop_providers.dart';
import 'package:petcare/features/shop/presentation/view_model/shop_view_model.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProvider);
    final cart = state.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearDialog(context, ref),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: context.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, _a) => Divider(color: context.borderColor),
              itemBuilder: (context, index) {
                return _CartItemTile(item: cart.items[index]);
              },
            ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        context.isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (cart.items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your cart is empty'),
                              ),
                            );
                            return;
                          }

                          final createOrderUsecase =
                              ref.read(createOrderUsecaseProvider);

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

                          final result = await createOrderUsecase(order);

                          result.fold(
                            (failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.message)),
                              );
                            },
                            (createdOrder) {
                              ref.read(shopProvider.notifier).clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Order placed successfully!'),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iconPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(shopProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.iconPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.iconPrimaryColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 12),

          // Name & price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.successColor,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: () {
                  if (item.quantity > 1) {
                    ref
                        .read(shopProvider.notifier)
                        .updateQuantity(
                          item.product.productId!,
                          item.quantity - 1,
                        );
                  } else {
                    ref
                        .read(shopProvider.notifier)
                        .removeFromCart(item.product.productId!);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: context.textPrimary,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: () {
                  ref
                      .read(shopProvider.notifier)
                      .updateQuantity(
                        item.product.productId!,
                        item.quantity + 1,
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: context.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: context.textPrimary),
      ),
    );
  }
}
