import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';

class PetVaccinationApiModel {
  final String vaccine;
  final int? recommendedByMonths;
  final int dosesTaken;
  final String status;

  const PetVaccinationApiModel({
    required this.vaccine,
    this.recommendedByMonths,
    this.dosesTaken = 0,
    this.status = 'pending',
  });

  factory PetVaccinationApiModel.fromJson(Map<String, dynamic> json) {
    return PetVaccinationApiModel(
      vaccine: (json['vaccine'] ?? '').toString(),
      recommendedByMonths: json['recommendedByMonths'] == null
          ? null
          : (json['recommendedByMonths'] as num).toInt(),
      dosesTaken: json['dosesTaken'] == null
          ? 0
          : (json['dosesTaken'] as num).toInt(),
      status: (json['status'] ?? 'pending').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccine': vaccine,
      if (recommendedByMonths != null)
        'recommendedByMonths': recommendedByMonths,
      'dosesTaken': dosesTaken,
      'status': status,
    };
  }

  PetVaccinationEntity toEntity() {
    return PetVaccinationEntity(
      vaccine: vaccine,
      recommendedByMonths: recommendedByMonths,
      dosesTaken: dosesTaken,
      status: status,
    );
  }

  factory PetVaccinationApiModel.fromEntity(PetVaccinationEntity entity) {
    return PetVaccinationApiModel(
      vaccine: entity.vaccine,
      recommendedByMonths: entity.recommendedByMonths,
      dosesTaken: entity.dosesTaken,
      status: entity.status,
    );
  }
}

class PetCareApiModel {
  final List<String> feedingTimes;
  final List<PetVaccinationApiModel> vaccinations;
  final String? notes;
  final String? updatedAt;

  const PetCareApiModel({
    this.feedingTimes = const [],
    this.vaccinations = const [],
    this.notes,
    this.updatedAt,
  });

  factory PetCareApiModel.fromJson(Map<String, dynamic> json) {
    final feedingTimesRaw = json['feedingTimes'];
    final vaccinationsRaw = json['vaccinations'];

    return PetCareApiModel(
      feedingTimes: feedingTimesRaw is List
          ? feedingTimesRaw.map((item) => item.toString()).toList()
          : const [],
      vaccinations: vaccinationsRaw is List
          ? vaccinationsRaw
                .whereType<Map<String, dynamic>>()
                .map(PetVaccinationApiModel.fromJson)
                .toList()
          : const [],
      notes: json['notes']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedingTimes': feedingTimes,
      'vaccinations': vaccinations.map((item) => item.toJson()).toList(),
      if (notes != null) 'notes': notes,
    };
  }

  PetCareEntity toEntity() {
    return PetCareEntity(
      feedingTimes: feedingTimes,
      vaccinations: vaccinations.map((item) => item.toEntity()).toList(),
      notes: notes,
      updatedAt: updatedAt == null ? null : DateTime.tryParse(updatedAt!),
    );
  }

  factory PetCareApiModel.fromEntity(PetCareEntity entity) {
    return PetCareApiModel(
      feedingTimes: entity.feedingTimes,
      vaccinations: entity.vaccinations
          .map(PetVaccinationApiModel.fromEntity)
          .toList(),
      notes: entity.notes,
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}
