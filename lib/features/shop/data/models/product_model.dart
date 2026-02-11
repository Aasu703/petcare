import 'package:petcare/features/shop/domain/entities/product_entity.dart';

class ProductModel {
  final String? id;
  final String productName;
  final String? description;
  final double? price;
  final int quantity;
  final String? category;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    this.id,
    required this.productName,
    this.description,
    this.price,
    this.quantity = 0,
    this.category,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  // FROM JSON — matches backend inventory model exactly
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      productName: json['product_name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : 0,
      category: json['category']?.toString(),
      providerId: json['providerId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  // TO JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'product_name': productName};
    if (description != null) json['description'] = description;
    if (price != null) json['price'] = price;
    json['quantity'] = quantity;
    if (category != null) json['category'] = category;
    if (providerId != null) json['providerId'] = providerId;
    return json;
  }

  // TO ENTITY
  ProductEntity toEntity() {
    return ProductEntity(
      productId: id,
      productName: productName,
      description: description,
      price: price,
      quantity: quantity,
      category: category,
      providerId: providerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // FROM ENTITY
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.productId,
      productName: entity.productName,
      description: entity.description,
      price: entity.price,
      quantity: entity.quantity,
      category: entity.category,
      providerId: entity.providerId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<ProductEntity> toEntityList(List<ProductModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
