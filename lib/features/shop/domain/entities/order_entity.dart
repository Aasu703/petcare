import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, productName, quantity, price];
}

class OrderEntity extends Equatable {
  final String? orderId;
  final String? userId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String? shippingAddress;
  final String? notes;
  final String? createdAt;

  const OrderEntity({
    this.orderId,
    this.userId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.shippingAddress,
    this.notes,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    userId,
    items,
    totalAmount,
    status,
    shippingAddress,
    notes,
    createdAt,
  ];
}
