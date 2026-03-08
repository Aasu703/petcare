import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/shop/domain/entities/order_entity.dart';
import 'package:petcare/features/shop/domain/usecases/update_provider_order_status_usecase.dart';
import 'package:petcare/features/shop/presentation/provider/shop_providers.dart';

class ProviderOrdersPage extends ConsumerStatefulWidget {
  const ProviderOrdersPage({super.key});

  @override
  ConsumerState<ProviderOrdersPage> createState() => _ProviderOrdersPageState();
}

class _ProviderOrdersPageState extends ConsumerState<ProviderOrdersPage> {
  bool _isLoading = true;
  String? _error;
  List<OrderEntity> _orders = const [];
  final Set<String> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final usecase = ref.read(getProviderOrdersUsecaseProvider);
    final result = await usecase();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.message;
          _orders = const [];
        });
      },
      (orders) {
        setState(() {
          _isLoading = false;
          _orders = orders;
        });
      },
    );
  }

  Future<void> _updateStatus(String orderId, String status) async {
    setState(() => _updatingIds.add(orderId));
    final usecase = ref.read(updateProviderOrderStatusUsecaseProvider);
    final result = await usecase(
      UpdateProviderOrderStatusParams(orderId: orderId, status: status),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _updatingIds.remove(orderId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (updatedOrder) {
        setState(() {
          _updatingIds.remove(orderId);
          _orders = _orders.map((order) {
            return order.orderId == updatedOrder.orderId ? updatedOrder : order;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $status')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppColors.iconPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade300,
                      size: 54,
                    ),
                    const SizedBox(height: 10),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadOrders,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final isUpdating =
                      order.orderId != null &&
                      _updatingIds.contains(order.orderId);
                  return _ProviderOrderCard(
                    order: order,
                    isUpdating: isUpdating,
                    onStatusChange: (status) {
                      final id = order.orderId;
                      if (id != null && id.isNotEmpty) {
                        _updateStatus(id, status);
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _ProviderOrderCard extends StatelessWidget {
  const _ProviderOrderCard({
    required this.order,
    required this.onStatusChange,
    this.isUpdating = false,
  });

  final OrderEntity order;
  final void Function(String status) onStatusChange;
  final bool isUpdating;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.orange;
      case 'delivered':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? isoDate) {
    final date = DateTime.tryParse(isoDate ?? '');
    if (date == null) return 'Unknown date';
    return DateFormat('MMM d, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = order.status.toLowerCase();
    final statusColor = _statusColor(normalizedStatus);
    final updatedText = order.updatedAt != null
        ? 'Updated ${_formatDate(order.updatedAt)}'
        : 'Created ${_formatDate(order.createdAt)}';
    final dropdownValue =
        _ProviderOrderStatusHelper.statusOptions.contains(normalizedStatus)
        ? normalizedStatus
        : _ProviderOrderStatusHelper.statusOptions.first;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderId ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dropdownValue[0].toUpperCase() + dropdownValue.substring(1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(updatedText, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              'Customer: ${order.userId ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (order.shippingAddress != null) ...[
              const SizedBox(height: 6),
              Text(
                order.shippingAddress!,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'} • '
              '\$${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: isUpdating
                      ? null
                      : (value) {
                          if (value != null) onStatusChange(value);
                        },
                  items: _ProviderOrderStatusHelper.statusOptions
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            if (isUpdating) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 3),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProviderOrderStatusHelper {
  static const List<String> statusOptions = <String>[
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];
}
