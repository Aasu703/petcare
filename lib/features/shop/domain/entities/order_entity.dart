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
  final String? providerId;
  final String? providerName;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String status; // pending, processing, shipped, delivered, cancelled
  final String? shippingAddress;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  const OrderEntity({
    this.orderId,
    this.userId,
    this.providerId,
    this.providerName,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.shippingAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    orderId,
    userId,
    providerId,
    providerName,
    items,
    totalAmount,
    status,
    shippingAddress,
    notes,
    createdAt,
    updatedAt,
  ];
}
