import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/core/providers/shared_prefs_provider.dart';
import 'package:petcare/core/services/notification/notification_service.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';

class _VaccineTemplate {
  final String vaccine;
  final int recommendedByMonths;

  const _VaccineTemplate({
    required this.vaccine,
    required this.recommendedByMonths,
  });
}

const Map<String, List<_VaccineTemplate>> _speciesTemplates = {
  'dog': [
    _VaccineTemplate(vaccine: 'DHPP', recommendedByMonths: 2),
    _VaccineTemplate(vaccine: 'Rabies', recommendedByMonths: 3),
    _VaccineTemplate(vaccine: 'Leptospirosis', recommendedByMonths: 3),
    _VaccineTemplate(vaccine: 'Bordetella', recommendedByMonths: 4),
  ],
  'cat': [
    _VaccineTemplate(vaccine: 'FVRCP', recommendedByMonths: 2),
    _VaccineTemplate(vaccine: 'Rabies', recommendedByMonths: 3),
    _VaccineTemplate(vaccine: 'FeLV', recommendedByMonths: 2),
  ],
  'bird': [_VaccineTemplate(vaccine: 'Polyomavirus', recommendedByMonths: 2)],
  'rabbit': [_VaccineTemplate(vaccine: 'RHDV2', recommendedByMonths: 2)],
};

class _VaccinationRow {
  final TextEditingController vaccineController;
  final TextEditingController recommendedByMonthsController;
  final TextEditingController dosesTakenController;
  String status;

  _VaccinationRow({
    required this.vaccineController,
    required this.recommendedByMonthsController,
    required this.dosesTakenController,
    required this.status,
  });

  void dispose() {
    vaccineController.dispose();
    recommendedByMonthsController.dispose();
    dosesTakenController.dispose();
  }
}

class _PendingFoodReminder {
  final String timeLabel;
  final int minutesFromNow;

  const _PendingFoodReminder({
    required this.timeLabel,
    required this.minutesFromNow,
  });
}

class PetCareScreen extends ConsumerStatefulWidget {
  final PetEntity pet;

  const PetCareScreen({super.key, required this.pet});

  @override
  ConsumerState<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends ConsumerState<PetCareScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _feedingTimes = [];
  final Map<String, bool> _feedingChecklist = {};
  final Set<String> _overdueNotifiedKeys = {};
  final List<_VaccinationRow> _vaccinationRows = [];
  static const Duration _pendingReminderInterval = Duration(minutes: 3);
  static const Duration _feedingReminderWindow = Duration(minutes: 30);
  Timer? _pendingReminderTimer;
  bool _isSaving = false;
  bool _isLoading = true;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int? get _ageMonths {
    if (widget.pet.age == null || widget.pet.age! < 0) return null;
    return (widget.pet.age! * 12).round();
  }

  List<_VaccineTemplate> get _templates {
    final species = widget.pet.species.toLowerCase().trim();
    return _speciesTemplates[species] ??
        const [_VaccineTemplate(vaccine: 'Rabies', recommendedByMonths: 3)];
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCare);
  }

  @override
  void dispose() {
    _pendingReminderTimer?.cancel();
    _notesController.dispose();
    for (final row in _vaccinationRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCare() async {
    final petId = widget.pet.petId;
    if (petId == null || petId.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final care = await ref.read(petNotifierProvider.notifier).getPetCare(petId);
    final merged = _mergeVaccinations(care?.vaccinations ?? const []);

    if (!mounted) return;
    setState(() {
      _feedingTimes
        ..clear()
        ..addAll(
          care != null && care.feedingTimes.isNotEmpty
              ? care.feedingTimes
              : const ['08:00', '18:00'],
        );
      _notesController.text = care?.notes ?? '';
      _setVaccinationRows(merged);
      _isLoading = false;
    });
    await _loadFeedingChecklist();
    _restartPendingReminders();
  }

  String _feedingChecklistKey(String petId) {
    return 'feeding_checklist:$petId:$_todayKey';
  }

  Future<void> _loadFeedingChecklist() async {
    final petId = widget.pet.petId;
    if (petId == null || petId.isEmpty) return;

    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_feedingChecklistKey(petId));
    Map<String, bool> restored = {};

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        restored = decoded.map((key, value) => MapEntry(key, value == true));
      } catch (_) {
        restored = {};
      }
    }

    final currentTimes = _feedingTimes.toSet();
    setState(() {
      _feedingChecklist
        ..clear()
        ..addAll(restored);
      _feedingChecklist.removeWhere((key, _) => !currentTimes.contains(key));
      for (final time in currentTimes) {
        _feedingChecklist.putIfAbsent(time, () => false);
      }
      _overdueNotifiedKeys.clear();
    });
    await _persistFeedingChecklist();
  }

  Future<void> _persistFeedingChecklist() async {
    final petId = widget.pet.petId;
    if (petId == null || petId.isEmpty) return;

    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(
      _feedingChecklistKey(petId),
      jsonEncode(_feedingChecklist),
    );
  }

  void _restartPendingReminders() {
    _pendingReminderTimer?.cancel();
    if (_isLoading) return;

    _pendingReminderTimer = Timer.periodic(_pendingReminderInterval, (_) async {
      if (!mounted) return;
      final now = DateTime.now();
      _showPendingReminderIfNeeded(now);
      await _triggerFeedingOverdueNotifications(now);
    });
  }

  void _showPendingReminderIfNeeded(DateTime now) {
    final pendingVaccinations = _pendingVaccinationNames();
    final pendingFood = _findPendingFoodReminder(now);
    if (pendingVaccinations.isEmpty && pendingFood == null) return;

    final messages = <String>[];

    if (pendingVaccinations.isNotEmpty) {
      final preview = pendingVaccinations.take(2).join(', ');
      final remaining = pendingVaccinations.length - 2;
      final suffix = remaining > 0 ? ' +$remaining more' : '';
      messages.add('Pending vaccination: $preview$suffix.');
    }

    if (pendingFood != null) {
      if (pendingFood.minutesFromNow >= 0) {
        messages.add(
          'Food reminder: feed ${widget.pet.name} at ${pendingFood.timeLabel} '
          '(in ${pendingFood.minutesFromNow} min).',
        );
      } else {
        messages.add(
          'Food reminder: ${widget.pet.name} feeding at '
          '${pendingFood.timeLabel} is pending.',
        );
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(messages.join('\n')),
          backgroundColor: AppColors.warningColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  List<String> _pendingVaccinationNames() {
    return _vaccinationRows
        .where((row) {
          if (row.status != 'pending') return false;

          final recommendedByMonths = int.tryParse(
            row.recommendedByMonthsController.text.trim(),
          );
          if (_ageMonths == null || recommendedByMonths == null) return true;
          return _ageMonths! >= recommendedByMonths;
        })
        .map((row) => row.vaccineController.text.trim())
        .where((name) {
          return name.isNotEmpty;
        })
        .toList();
  }

  _PendingFoodReminder? _findPendingFoodReminder(DateTime now) {
    _PendingFoodReminder? bestReminder;

    for (final feedingTime in _feedingTimes) {
      if (_feedingChecklist[feedingTime] == true) continue;
      final parsed = _parseTime(feedingTime);
      if (parsed == null) continue;

      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        parsed.hour,
        parsed.minute,
      );
      final minutesFromNow = scheduled.difference(now).inMinutes;
      final absoluteMinutes = minutesFromNow.abs();
      if (absoluteMinutes > _feedingReminderWindow.inMinutes) continue;

      final bestAbsolute = bestReminder?.minutesFromNow.abs() ?? 999999;
      if (absoluteMinutes < bestAbsolute) {
        bestReminder = _PendingFoodReminder(
          timeLabel: feedingTime,
          minutesFromNow: minutesFromNow,
        );
      }
    }

    return bestReminder;
  }

  Future<void> _triggerFeedingOverdueNotifications(DateTime now) async {
    final petId = widget.pet.petId;
    if (petId == null || petId.isEmpty) return;

    final notificationService = ref.read(notificationServiceProvider);

    for (final feedingTime in _feedingTimes) {
      if (_feedingChecklist[feedingTime] == true) continue;
      final parsed = _parseTime(feedingTime);
      if (parsed == null) continue;

      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        parsed.hour,
        parsed.minute,
      );
      final minutesLate = now.difference(scheduled).inMinutes;
      if (minutesLate <= 0) continue;

      final key = '$petId:$_todayKey:$feedingTime';
      if (_overdueNotifiedKeys.contains(key)) continue;

      final success = await notificationService.showInstantNotification(
        id: NotificationService.createEphemeralId(),
        title: 'Feeding overdue',
        body:
            '${widget.pet.name} feeding at $feedingTime is overdue by $minutesLate min.',
      );

      if (success) {
        _overdueNotifiedKeys.add(key);
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.pet.name} feeding at $feedingTime is overdue by $minutesLate min.',
                ),
                backgroundColor: AppColors.errorColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
        }
      }
    }
  }

  void _setVaccinationRows(List<PetVaccinationEntity> vaccinations) {
    for (final row in _vaccinationRows) {
      row.dispose();
    }
    _vaccinationRows
      ..clear()
      ..addAll(
        vaccinations.map(
          (item) => _VaccinationRow(
            vaccineController: TextEditingController(text: item.vaccine),
            recommendedByMonthsController: TextEditingController(
              text: item.recommendedByMonths?.toString() ?? '',
            ),
            dosesTakenController: TextEditingController(
              text: item.dosesTaken.toString(),
            ),
            status: item.status,
          ),
        ),
      );
  }

  List<PetVaccinationEntity> _mergeVaccinations(
    List<PetVaccinationEntity> existing,
  ) {
    final map = <String, PetVaccinationEntity>{};

    for (final item in existing) {
      final key = item.vaccine.trim().toLowerCase();
      if (key.isEmpty) continue;
      map[key] = item.copyWith(vaccine: item.vaccine.trim());
    }

    for (final template in _templates) {
      final key = template.vaccine.toLowerCase();
      final current = map[key];
      if (current == null) {
        map[key] = PetVaccinationEntity(
          vaccine: template.vaccine,
          recommendedByMonths: template.recommendedByMonths,
          dosesTaken: 0,
          status: 'pending',
        );
      } else if (current.recommendedByMonths == null) {
        map[key] = current.copyWith(
          recommendedByMonths: template.recommendedByMonths,
        );
      }
    }

    final values = map.values.toList();
    values.sort((a, b) {
      final left = a.recommendedByMonths ?? 999;
      final right = b.recommendedByMonths ?? 999;
      return left.compareTo(right);
    });
    return values;
  }

  String _dueLabel(int? recommendedByMonths) {
    if (recommendedByMonths == null) return 'No schedule';
    if (_ageMonths == null) return 'Recommended by $recommendedByMonths months';
    if (_ageMonths! >= recommendedByMonths) return 'Due now';
    return 'Due in ${recommendedByMonths - _ageMonths!} months';
  }

  Future<void> _pickTime({int? index}) async {
    final initial = index == null
        ? const TimeOfDay(hour: 8, minute: 0)
        : _parseTime(_feedingTimes[index]) ??
              const TimeOfDay(hour: 8, minute: 0);

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final formatted = _formatTime(picked);

    if (!mounted) return;
    setState(() {
      if (index == null) {
        _feedingTimes.add(formatted);
      } else {
        _feedingTimes[index] = formatted;
      }
    });
    await _syncChecklistWithTimes();
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _addVaccination() {
    setState(() {
      _vaccinationRows.add(
        _VaccinationRow(
          vaccineController: TextEditingController(),
          recommendedByMonthsController: TextEditingController(),
          dosesTakenController: TextEditingController(text: '0'),
          status: 'pending',
        ),
      );
    });
  }

  void _removeVaccination(int index) {
    setState(() {
      final row = _vaccinationRows.removeAt(index);
      row.dispose();
    });
  }

  Future<void> _removeFeedingTime(int index) async {
    setState(() => _feedingTimes.removeAt(index));
    await _syncChecklistWithTimes();
  }

  Future<void> _syncChecklistWithTimes() async {
    final currentTimes = _feedingTimes.toSet();
    var changed = false;

    setState(() {
      final toRemove = _feedingChecklist.keys
          .where((time) => !currentTimes.contains(time))
          .toList();
      for (final time in toRemove) {
        _feedingChecklist.remove(time);
        changed = true;
      }

      for (final time in currentTimes) {
        if (!_feedingChecklist.containsKey(time)) {
          _feedingChecklist[time] = false;
          changed = true;
        }
      }

      if (!changed) return;
      _overdueNotifiedKeys.removeWhere((key) {
        return !_feedingChecklist.keys.any((time) => key.endsWith(':$time'));
      });
    });

    if (changed) {
      await _persistFeedingChecklist();
    }
  }

  Future<void> _toggleFeedingStatus(String time, bool value) async {
    setState(() {
      _feedingChecklist[time] = value;
      if (!value) {
        _overdueNotifiedKeys.removeWhere((key) => key.endsWith(':$time'));
      }
    });
    await _persistFeedingChecklist();
  }

  bool _isFeedingOverdue(String time, DateTime now) {
    final parsed = _parseTime(time);
    if (parsed == null) return false;
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      parsed.hour,
      parsed.minute,
    );
    return now.isAfter(scheduled);
  }

  String _feedingStatusLabel(String time, DateTime now) {
    final parsed = _parseTime(time);
    if (parsed == null) return 'Schedule unavailable';
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      parsed.hour,
      parsed.minute,
    );
    final minutesDiff = scheduled.difference(now).inMinutes;
    if (minutesDiff > 0) return 'Due in $minutesDiff min';
    if (minutesDiff == 0) return 'Due now';
    return 'Overdue by ${minutesDiff.abs()} min';
  }

  Future<void> _saveCare() async {
    final petId = widget.pet.petId;
    if (petId == null || petId.isEmpty) {
      _showSnack('Missing pet id', isError: true);
      return;
    }

    if (_feedingTimes.isEmpty) {
      _showSnack('Add at least one feeding time', isError: true);
      return;
    }

    final vaccinations = <PetVaccinationEntity>[];
    final vaccineNames = <String>{};

    for (final row in _vaccinationRows) {
      final name = row.vaccineController.text.trim();
      if (name.isEmpty) {
        _showSnack('Vaccine name cannot be empty', isError: true);
        return;
      }

      final key = name.toLowerCase();
      if (vaccineNames.contains(key)) {
        _showSnack('Duplicate vaccine names are not allowed', isError: true);
        return;
      }
      vaccineNames.add(key);

      final recommended = row.recommendedByMonthsController.text.trim();
      final doses = row.dosesTakenController.text.trim();

      vaccinations.add(
        PetVaccinationEntity(
          vaccine: name,
          recommendedByMonths: recommended.isEmpty
              ? null
              : int.tryParse(recommended),
          dosesTaken: int.tryParse(doses) ?? 0,
          status: row.status,
        ),
      );
    }

    final care = PetCareEntity(
      feedingTimes: List<String>.from(_feedingTimes),
      vaccinations: vaccinations,
      notes: _notesController.text.trim(),
    );

    setState(() => _isSaving = true);
    final success = await ref
        .read(petNotifierProvider.notifier)
        .updatePetCare(petId, care);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSnack('Pet care saved');
    } else {
      _showSnack(
        ref.read(petNotifierProvider).error ?? 'Failed to save pet care',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.errorColor
            : AppColors.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _vaccinationRows
        .where((row) => row.status == 'done')
        .length;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          '${widget.pet.name} Care',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Feeding Timetable',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (
                                      int i = 0;
                                      i < _feedingTimes.length;
                                      i++
                                    )
                                      InputChip(
                                        label: Text(_feedingTimes[i]),
                                        onPressed: () => _pickTime(index: i),
                                        onDeleted: _feedingTimes.length == 1
                                            ? null
                                            : () => _removeFeedingTime(i),
                                        avatar: const Icon(
                                          Icons.schedule,
                                          size: 18,
                                        ),
                                      ),
                                    ActionChip(
                                      label: const Text('Add time'),
                                      avatar: const Icon(Icons.add, size: 18),
                                      onPressed: () => _pickTime(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Today's Feeding Checklist",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_feedingChecklist.values.where((done) => done).length}/${_feedingTimes.length} done',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_feedingTimes.isEmpty)
                                  const Text('Add at least one feeding time'),
                                for (final time in _feedingTimes)
                                  CheckboxListTile(
                                    value: _feedingChecklist[time] ?? false,
                                    title: Text(time),
                                    subtitle: Text(
                                      _feedingStatusLabel(time, now),
                                      style: TextStyle(
                                        color: _isFeedingOverdue(time, now)
                                            ? AppColors.errorColor
                                            : context.textSecondary,
                                      ),
                                    ),
                                    secondary: Icon(
                                      _feedingChecklist[time] == true
                                          ? Icons.check_circle
                                          : Icons.access_time,
                                      color: _feedingChecklist[time] == true
                                          ? AppColors.successColor
                                          : (_isFeedingOverdue(time, now)
                                                ? AppColors.errorColor
                                                : context.textSecondary),
                                    ),
                                    onChanged: (value) {
                                      _toggleFeedingStatus(
                                        time,
                                        value ?? false,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Vaccination Checklist',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$completed/${_vaccinationRows.length} done',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                for (
                                  int i = 0;
                                  i < _vaccinationRows.length;
                                  i++
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildVaccinationCard(
                                      _vaccinationRows[i],
                                      i,
                                    ),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: _addVaccination,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add vaccine'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Care Notes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesController,
                                  minLines: 3,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Add food preferences or reminders...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveCare,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save Care Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimaryColor,
                          foregroundColor: AppColors.buttonTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVaccinationCard(_VaccinationRow row, int index) {
    final recommendedByMonths = int.tryParse(
      row.recommendedByMonthsController.text.trim(),
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.vaccineController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccine',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeVaccination(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.recommendedByMonthsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Recommended by (months)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.dosesTakenController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Doses taken',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: row.status,
            decoration: const InputDecoration(
              labelText: 'Status (MCQ)',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'done', child: Text('Done')),
              DropdownMenuItem(
                value: 'not_required',
                child: Text('Not Required'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => row.status = value);
            },
          ),
          const SizedBox(height: 6),
          Text(
            _dueLabel(recommendedByMonths),
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}
