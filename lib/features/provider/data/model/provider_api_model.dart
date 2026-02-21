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
  final double? locationLatitude;
  final double? locationLongitude;
  final String? locationAddress;
  final bool locationVerified;
  final bool pawcareVerified;
  final String? status;

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
    this.locationLatitude,
    this.locationLongitude,
    this.locationAddress,
    this.locationVerified = false,
    this.pawcareVerified = false,
    this.status,
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
    if (locationLatitude != null && locationLongitude != null) {
      json["location"] = {
        "latitude": locationLatitude,
        "longitude": locationLongitude,
        "address": locationAddress ?? "",
      };
    }
    return json;
  }

  // FROM JSON (From API)
  factory ProviderApiModel.fromJson(Map<String, dynamic> json) {
    int parseRating(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) {
        final parsedInt = int.tryParse(value);
        if (parsedInt != null) return parsedInt;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.round();
      }
      return 0;
    }

    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ProviderApiModel(
      providerId: (json["_id"] ?? json["provider_id"])?.toString(),
      userId: (json["userId"] ?? json["user_id"])?.toString() ?? '',
      businessName:
          (json["businessName"] ?? json["business_name"])?.toString() ?? '',
      address: json["address"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      rating: parseRating(json["rating"]),
      providerType: json["providerType"]?.toString(),
      email: json["email"]?.toString(),
      password: json["password"]?.toString(),
      locationLatitude: parseCoordinate(
        (json["location"] as Map?)?["latitude"] ?? json["latitude"],
      ),
      locationLongitude: parseCoordinate(
        (json["location"] as Map?)?["longitude"] ?? json["longitude"],
      ),
      locationAddress:
          (json["location"] as Map?)?["address"]?.toString() ??
          json["locationAddress"]?.toString(),
      locationVerified: json["locationVerified"] == true,
      pawcareVerified: json["pawcareVerified"] == true,
      status: json["status"]?.toString(),
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
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationAddress: locationAddress,
      locationVerified: locationVerified,
      pawcareVerified: pawcareVerified,
      status: status,
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
      locationLatitude: entity.locationLatitude,
      locationLongitude: entity.locationLongitude,
      locationAddress: entity.locationAddress,
      locationVerified: entity.locationVerified,
      pawcareVerified: entity.pawcareVerified,
      status: entity.status,
    );
  }

  // TO ENTITY LIST
  static List<ProviderEntity> toEntityList(List<ProviderApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
