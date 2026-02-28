import 'package:equatable/equatable.dart';

class PetVaccinationEntity extends Equatable {
  final String vaccine;
  final int? recommendedByMonths;
  final int dosesTaken;
  final String status; // pending | done | not_required

  const PetVaccinationEntity({
    required this.vaccine,
    this.recommendedByMonths,
    this.dosesTaken = 0,
    this.status = 'pending',
  });

  PetVaccinationEntity copyWith({
    String? vaccine,
    int? recommendedByMonths,
    int? dosesTaken,
    String? status,
  }) {
    return PetVaccinationEntity(
      vaccine: vaccine ?? this.vaccine,
      recommendedByMonths: recommendedByMonths ?? this.recommendedByMonths,
      dosesTaken: dosesTaken ?? this.dosesTaken,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [vaccine, recommendedByMonths, dosesTaken, status];
}

class PetCareEntity extends Equatable {
  final List<String> feedingTimes;
  final List<PetVaccinationEntity> vaccinations;
  final String? notes;
  final DateTime? updatedAt;

  const PetCareEntity({
    this.feedingTimes = const [],
    this.vaccinations = const [],
    this.notes,
    this.updatedAt,
  });

  PetCareEntity copyWith({
    List<String>? feedingTimes,
    List<PetVaccinationEntity>? vaccinations,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PetCareEntity(
      feedingTimes: feedingTimes ?? this.feedingTimes,
      vaccinations: vaccinations ?? this.vaccinations,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [feedingTimes, vaccinations, notes, updatedAt];
}
