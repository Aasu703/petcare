import '../../domain/entities/provider_entity.dart';

class ProviderApiModel {
  final String? providerId;
  final String userId; // FK
  final String businessName;
  final String address;
  final String phone;
  final int rating;

  ProviderApiModel({
    this.providerId,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.rating,
  });

  // TO JSON (Send to API)
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "business_name": businessName,
      "address": address,
      "phone": phone,
      "rating": rating,
    };
  }

  // FROM JSON (From API)
  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderApiModel(
      providerId: (json["_id"] ?? json["provider_id"])?.toString(),
      userId: json["user_id"].toString(),
      businessName: json["business_name"],
      address: json["address"],
      phone: json["phone"],
      rating: json["rating"] ?? 0,
    );
  }

  // TO ENTITY
  ProviderEntity toEntity() {
    return ProviderEntity(
      providerId: providerId ?? '',
      userId: userId,
      businessName: businessName,
      address: address,
      phone: phone,
      rating: rating,
    );
  }

  // FROM ENTITY
  factory ProviderApiModel.fromEntity(ProviderEntity entity) {
    return ProviderApiModel(
      providerId: entity.providerId,
      userId: entity.userId,
      businessName: entity.businessName,
      address: entity.address,
      phone: entity.phone,
      rating: entity.rating,
    );
  }

  // TO ENTITY LIST
  static List<ProviderEntity> toEntityList(List<ProviderApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
