import '../../domain/entities/provider_entity.dart';

class ProviderApiModel {
  final String? providerId;
  final String userId; // FK
  final String businessName;
  final String address;
  final String phone;
  final int rating;
  final String? providerType;
  final String? email;
  final String? password;
  final String? confirmPassword;

  ProviderApiModel({
    this.providerId,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.rating,
    this.providerType,
    this.email,
    this.password,
    this.confirmPassword,
  });

  // TO JSON (Send to API)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      "businessName": businessName,
      "address": address,
      "phone": phone,
    };
    if (email != null) json["email"] = email;
    if (password != null) json["password"] = password;
    if (confirmPassword != null) json["confirmPassword"] = confirmPassword;
    if (providerType != null) json["providerType"] = providerType;
    return json;
  }

  // FROM JSON (From API)
  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    return ProviderApiModel(
      providerId: (json["_id"] ?? json["provider_id"])?.toString(),
      userId: (json["userId"] ?? json["user_id"])?.toString() ?? '',
      businessName:
          (json["businessName"] ?? json["business_name"])?.toString() ?? '',
      address: json["address"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      rating: json["rating"] ?? 0,
      providerType: json["providerType"]?.toString(),
      email: json["email"]?.toString(),
      password: json["password"]?.toString(),
    );
  }

  // TO ENTITY
  ProviderEntity toEntity() {
    return ProviderEntity(
      providerId: providerId,
      userId: userId,
      businessName: businessName,
      address: address,
      phone: phone,
      rating: rating,
      providerType: providerType,
      email: email,
      password: password,
    );
  }

  // FROM ENTITY
  factory ProviderApiModel.fromEntity(ProviderEntity entity) {
    return ProviderApiModel(
      providerId: entity.providerId,
      userId: entity.userId ?? '',
      businessName: entity.businessName,
      address: entity.address,
      phone: entity.phone,
      rating: entity.rating,
      providerType: entity.providerType,
      email: entity.email,
      password: entity.password,
    );
  }

  // TO ENTITY LIST
  static List<ProviderEntity> toEntityList(List<ProviderApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
