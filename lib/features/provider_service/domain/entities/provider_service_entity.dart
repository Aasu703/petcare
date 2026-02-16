import 'package:equatable/equatable.dart';

class ProviderServiceEntity extends Equatable {
  final String? providerServiceId;
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

  const ProviderServiceEntity({
    this.providerServiceId,
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

  @override
  List<Object?> get props => [
    providerServiceId,
    userId,
    serviceType,
    verificationStatus,
    documents,
    registrationNumber,
    bio,
    experience,
    ratingAverage,
    ratingCount,
    earnings,
    createdAt,
    updatedAt,
  ];

  ProviderServiceEntity copyWith({
    String? providerServiceId,
    String? userId,
    String? serviceType,
    String? verificationStatus,
    List<String>? documents,
    String? registrationNumber,
    String? bio,
    String? experience,
    double? ratingAverage,
    int? ratingCount,
    double? earnings,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProviderServiceEntity(
      providerServiceId: providerServiceId ?? this.providerServiceId,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      documents: documents ?? this.documents,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      earnings: earnings ?? this.earnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
