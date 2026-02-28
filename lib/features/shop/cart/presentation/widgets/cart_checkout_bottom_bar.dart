import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/shop/cart/presentation/widgets/cart_summary_card.dart';
import 'package:petcare/features/shop/domain/entities/cart_entity.dart';

class CartCheckoutBottomBar extends StatelessWidget {
  final CartEntity cart;
  final bool isCheckingOut;
  final VoidCallback onCheckout;

  const CartCheckoutBottomBar({
    super.key,
    required this.cart,
    required this.isCheckingOut,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDark ? 0.2 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CartSummaryCard(
          cart: cart,
          isCheckingOut: isCheckingOut,
          onCheckout: onCheckout,
        ),
      ),
    );
  }
}
