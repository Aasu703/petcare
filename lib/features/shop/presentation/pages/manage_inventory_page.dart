import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/shop/di/shop_providers.dart';
import 'package:petcare/features/shop/domain/entities/product_entity.dart';
import 'package:petcare/features/shop/domain/repositories/shop_repository.dart';
import 'package:petcare/features/shop/presentation/view_model/shop_view_model.dart';

class ManageInventoryPage extends ConsumerStatefulWidget {
  const ManageInventoryPage({super.key});

  @override
  ConsumerState<ManageInventoryPage> createState() =>
      _ManageInventoryPageState();
}

class _ManageInventoryPageState extends ConsumerState<ManageInventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inventory'),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        onPressed: () => _showProductDialog(context),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text(state.error!))
          : state.products.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No inventory items yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap + to add your first product',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadInventory(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return _InventoryItemCard(
                    product: product,
                    onEdit: () => _showProductDialog(
                      context,
                      existing: product,
                    ),
                    onDelete: () => _deleteProduct(context, product),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _loadInventory() async {
    final session = ref.read(userSessionServiceProvider);
    final providerId = session.getUserId();

    // If we have a provider ID, load inventory scoped to this provider.
    // Fallback to generic products list otherwise.
    if (providerId != null && providerId.isNotEmpty) {
      await ref.read(shopProvider.notifier).loadProviderInventory(providerId);
    } else {
      await ref.read(shopProvider.notifier).loadProducts();
    }
  }

  Future<void> _deleteProduct(
    BuildContext context,
    ProductEntity product,
  ) async {
    if (product.productId == null || product.productId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid product identifier')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text(
              'Are you sure you want to delete "${product.productName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final repo = ref.read(shopRepositoryProvider);
    final result = await repo.deleteProduct(product.productId!);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (success) async {
        if (success) {
          await ref.read(shopProvider.notifier).loadProducts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete product')),
          );
        }
      },
    );
  }

  void _showProductDialog(BuildContext context, {ProductEntity? existing}) {
    final nameController = TextEditingController(
      text: existing?.productName ?? '',
    );
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.price?.toStringAsFixed(2) ?? '',
    );
    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '',
    );
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product name is required')),
                );
                return;
              }

              final repo = ref.read(shopRepositoryProvider);
              final parsedPrice =
                  double.tryParse(priceController.text.trim());
              final parsedQuantity =
                  int.tryParse(quantityController.text.trim()) ?? 0;

              final baseEntity = ProductEntity(
                productId: existing?.productId,
                productName: nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                price: parsedPrice,
                quantity: parsedQuantity,
                category: categoryController.text.trim().isEmpty
                    ? null
                    : categoryController.text.trim(),
                providerId: existing?.providerId,
              );

              final result = existing == null
                  ? await repo.createProduct(baseEntity)
                  : await repo.updateProduct(baseEntity);

              result.fold(
                (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(failure.message)),
                  );
                },
                (product) async {
                  Navigator.pop(context);
                  await ref.read(shopProvider.notifier).loadProducts();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existing != null
                            ? 'Product updated successfully'
                            : 'Product added successfully',
                      ),
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            child: Text(existing != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InventoryItemCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.quantity <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.inventory_2, color: Color(0xFFF59E0B)),
        ),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.category != null)
              Text(
                product.category!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (product.price != null)
                  Text(
                    '\$${product.price!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.successColor,
                    ),
                  ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Qty: ${product.quantity}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLowStock ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                if (isLowStock) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
