import 'package:flutter/material.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class CartEmptyState extends StatelessWidget {
  final VoidCallback? onBack;

  const CartEmptyState({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          if (onBack != null)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: context.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 16, color: context.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
