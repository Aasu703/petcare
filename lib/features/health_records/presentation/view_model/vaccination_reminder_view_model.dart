import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/services/notification/notification_service.dart';
import 'package:petcare/features/health_records/di/health_record_providers.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';
import 'package:petcare/features/health_records/domain/usecases/get_health_records_by_pet_usecase.dart';
import 'package:petcare/features/health_records/presentation/state/vaccination_reminder_state.dart';

class VaccinationReminderNotifier
    extends StateNotifier<VaccinationReminderState> {
  final Ref _ref;

  VaccinationReminderNotifier(this._ref)
    : super(const VaccinationReminderState());

  Future<void> loadReminders(List<String> petIds) async {
    if (petIds.isEmpty) {
      state = state.copyWith(reminders: [], loadedPetIds: const []);
      return;
    }

    final normalized = List<String>.from(petIds)..sort();
    final current = List<String>.from(state.loadedPetIds)..sort();
    if (normalized.length == current.length) {
      var same = true;
      for (var i = 0; i < normalized.length; i++) {
        if (normalized[i] != current[i]) {
          same = false;
          break;
        }
      }
      if (same && state.reminders.isNotEmpty) return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final usecase = _ref.read(getHealthRecordsByPetUsecaseProvider);
      final allRecords = <HealthRecordEntity>[];

      for (final petId in petIds) {
        final result = await usecase(GetHealthRecordsByPetParams(petId: petId));
        result.fold(
          (failure) => throw Exception(failure.message),
          (records) => allRecords.addAll(records),
        );
      }

      final now = DateTime.now();
      final upcoming = allRecords.where((record) {
        final nextDue = DateTime.tryParse(record.nextDueDate ?? '');
        if (nextDue == null) return false;
        return nextDue.isAfter(now);
      }).toList();

      upcoming.sort((a, b) {
        final aDate = DateTime.tryParse(a.nextDueDate ?? '') ?? now;
        final bDate = DateTime.tryParse(b.nextDueDate ?? '') ?? now;
        return aDate.compareTo(bDate);
      });

      final notificationService = _ref.read(notificationServiceProvider);
      for (final record in upcoming) {
        final dueDate = DateTime.tryParse(record.nextDueDate ?? '');
        if (dueDate == null || record.recordId == null) continue;
        await notificationService.scheduleVaccinationReminder(
          recordNotificationId:
              NotificationService.healthRecordIdToNotificationId(
                record.recordId!,
              ),
          dueDate: dueDate,
          title: 'Vaccination Reminder',
          body: record.title ?? 'A vaccination is due soon.',
        );
      }

      state = state.copyWith(
        isLoading: false,
        reminders: upcoming,
        loadedPetIds: petIds,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final vaccinationReminderProvider =
    StateNotifierProvider<
      VaccinationReminderNotifier,
      VaccinationReminderState
    >((ref) => VaccinationReminderNotifier(ref));
