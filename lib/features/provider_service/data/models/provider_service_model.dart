import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';

class ProviderServiceModel {
  final String? id;
  final String? userId;
  final String serviceType;
  final String verificationStatus;
  final List<String> documents;
  final String? registrationNumber;
  final String? bio;
  final String? experience;
  final double? ratingAverage;
  final int? ratingCount;
  final double? earnings;
  final String? createdAt;
  final String? updatedAt;

  ProviderServiceModel({
    this.id,
    this.userId,
    required this.serviceType,
    this.verificationStatus = 'pending',
    this.documents = const [],
    this.registrationNumber,
    this.bio,
    this.experience,
    this.ratingAverage,
    this.ratingCount,
    this.earnings,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      userId: json['userId']?.toString(),
      serviceType: json['serviceType']?.toString() ?? '',
      verificationStatus: json['verificationStatus']?.toString() ?? 'pending',
      documents:
          (json['documents'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      registrationNumber: json['registrationNumber']?.toString(),
      bio: json['bio']?.toString(),
      experience: json['experience']?.toString(),
      ratingAverage: (json['ratingAverage'] is num)
          ? (json['ratingAverage'] as num).toDouble()
          : null,
      ratingCount: (json['ratingCount'] is num)
          ? (json['ratingCount'] as num).toInt()
          : null,
      earnings: (json['earnings'] is num)
          ? (json['earnings'] as num).toDouble()
          : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJsonForApply() {
    final json = <String, dynamic>{'serviceType': serviceType};
    if (registrationNumber != null) {
      json['registrationNumber'] = registrationNumber;
    }
    if (bio != null) json['bio'] = bio;
    if (experience != null) json['experience'] = experience;
    if (documents.isNotEmpty) json['documents'] = documents;
    return json;
  }

  ProviderServiceEntity toEntity() {
    return ProviderServiceEntity(
      providerServiceId: id,
      userId: userId,
      serviceType: serviceType,
      verificationStatus: verificationStatus,
      documents: documents,
      registrationNumber: registrationNumber,
      bio: bio,
      experience: experience,
      ratingAverage: ratingAverage,
      ratingCount: ratingCount,
      earnings: earnings,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProviderServiceModel.fromEntity(ProviderServiceEntity entity) {
    return ProviderServiceModel(
      id: entity.providerServiceId,
      userId: entity.userId,
      serviceType: entity.serviceType,
      verificationStatus: entity.verificationStatus,
      documents: entity.documents,
      registrationNumber: entity.registrationNumber,
      bio: entity.bio,
      experience: entity.experience,
      ratingAverage: entity.ratingAverage,
      ratingCount: entity.ratingCount,
      earnings: entity.earnings,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<ProviderServiceEntity> toEntityList(
    List<ProviderServiceModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}
