import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';

class VaccinationReminderState {
  final bool isLoading;
  final String? error;
  final List<HealthRecordEntity> reminders;
  final List<String> loadedPetIds;

  const VaccinationReminderState({
    this.isLoading = false,
    this.error,
    this.reminders = const [],
    this.loadedPetIds = const [],
  });

  VaccinationReminderState copyWith({
    bool? isLoading,
    String? error,
    List<HealthRecordEntity>? reminders,
    List<String>? loadedPetIds,
  }) {
    return VaccinationReminderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reminders: reminders ?? this.reminders,
      loadedPetIds: loadedPetIds ?? this.loadedPetIds,
    );
  }
}
