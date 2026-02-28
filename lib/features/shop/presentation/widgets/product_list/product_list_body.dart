import 'package:flutter/material.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/presentation/widgets/product_list/product_card.dart';
import 'package:petcare/shared/widgets/index.dart';

/// Shop product list body with loading, empty, error, and grid states
class ProductListBody extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<ProductEntity> products;

  const ProductListBody({
    super.key,
    required this.isLoading,
    required this.error,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (error != null) {
      return ErrorState(
        title: 'Unable to load products',
        message: error,
        icon: Icons.storefront,
      );
    }

    if (products.isEmpty) {
      return const EmptyState(
        title: 'No products available',
        icon: Icons.storefront,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
