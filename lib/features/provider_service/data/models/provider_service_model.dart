import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';

class ProviderServiceModel {
  final String? id;
  final String? userId;
  final String title;
  final String? description;
  final String category;
  final double price;
  final int durationMinutes;
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
  final String approvalStatus;

  ProviderServiceModel({
    this.id,
    this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.price,
    required this.durationMinutes,
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
    this.approvalStatus = 'pending',
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      userId: json['userId']?.toString(),
      title: (json['title'] ?? json['serviceType'] ?? '').toString(),
      description: json['description']?.toString(),
      category: (json['category'] ?? json['serviceType'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      durationMinutes: (json['duration_minutes'] is num)
          ? (json['duration_minutes'] as num).toInt()
          : int.tryParse(json['durationMinutes']?.toString() ?? '0') ?? 0,
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
      approvalStatus: json['approvalStatus']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJsonForApply() {
    final json = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'duration_minutes': durationMinutes,
    };
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
      title: title,
      description: description,
      category: category,
      price: price,
      durationMinutes: durationMinutes,
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
      approvalStatus: approvalStatus,
    );
  }

  factory ProviderServiceModel.fromEntity(ProviderServiceEntity entity) {
    return ProviderServiceModel(
      id: entity.providerServiceId,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      price: entity.price,
      durationMinutes: entity.durationMinutes,
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
      approvalStatus: entity.approvalStatus,
    );
  }

  static List<ProviderServiceEntity> toEntityList(
    List<ProviderServiceModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}
