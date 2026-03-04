import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String? serviceId;
  final String title;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final List<String> availability;
  final String? providerId;
  final String approvalStatus;

  const ServiceEntity({
    this.serviceId,
    required this.title,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
    this.availability = const [],
    this.providerId,
    this.approvalStatus = 'pending',
  });

  @override
  List<Object?> get props => [
    serviceId,
    title,
    description,
    price,
    durationMinutes,
    category,
    availability,
    providerId,
    approvalStatus,
  ];

  ServiceEntity copyWith({
    String? serviceId,
    String? title,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    List<String>? availability,
    String? providerId,
    String? approvalStatus,
  }) {
    return ServiceEntity(
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      availability: availability ?? this.availability,
      providerId: providerId ?? this.providerId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}
