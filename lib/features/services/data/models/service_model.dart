import 'package:petcare/features/services/domain/entities/service_entity.dart';

class ServiceModel {
  final String? id;
  final String title;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final List<String> availability;
  final String? providerId;

  ServiceModel({
    this.id,
    required this.title,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
    this.availability = const [],
    this.providerId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      category: json['catergory']?.toString() ?? json['category']?.toString(),
      availability:
          (json['availability'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      providerId: json['providerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'catergory': category,
      'availability': availability,
      'providerId': providerId,
    };
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      serviceId: id,
      title: title,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      category: category,
      availability: availability,
      providerId: providerId,
    );
  }

  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.serviceId,
      title: entity.title,
      description: entity.description,
      price: entity.price,
      durationMinutes: entity.durationMinutes,
      category: entity.category,
      availability: entity.availability,
      providerId: entity.providerId,
    );
  }

  static List<ServiceEntity> toEntityList(List<ServiceModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
