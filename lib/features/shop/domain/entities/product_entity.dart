import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String? productId;
  final String productName;
  final String? description;
  final double? price;
  final int quantity;
  final String? category;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;

  const ProductEntity({
    this.productId,
    required this.productName,
    this.description,
    this.price,
    this.quantity = 0,
    this.category,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    description,
    price,
    quantity,
    category,
    providerId,
    createdAt,
    updatedAt,
  ];

  ProductEntity copyWith({
    String? productId,
    String? productName,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? providerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
