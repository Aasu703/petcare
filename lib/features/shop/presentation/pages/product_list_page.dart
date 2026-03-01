import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:petcare/features/shop/presentation/pages/product_detail_page.dart';
import 'package:petcare/features/shop/cart/presentation/pages/cart_page.dart';
import 'package:petcare/features/shop/cart/presentation/view_model/cart_view_model.dart';
import 'package:petcare/features/map/presentation/pages/nearby_map_screen.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'Nearby Pet Shops',
            onPressed: () async {
              try {
                final position = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.medium,
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NearbyMapScreen(
                      latitude: position.latitude,
                      longitude: position.longitude,
                      initialMode: NearbyMapMode.petShop,
                    ),
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to get location. Please enable location services.')),
                );
              }
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final cart = ref.watch(cartEntityProvider);
              final itemCount = cart.items.length;
              return IconButton(
                icon: Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text('$itemCount'),
                  child: const Icon(Icons.shopping_cart_rounded),
                ),
                tooltip: 'Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text('Error: ${state.error}'))
          : state.products.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No products available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                return _ProductCard(product: state.products[index]);
              },
            ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductEntity product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 48,
                    color: AppColors.iconPrimaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (product.price != null)
                Text(
                  '\$${product.price!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.successColor,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.productName} added to cart'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iconPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
