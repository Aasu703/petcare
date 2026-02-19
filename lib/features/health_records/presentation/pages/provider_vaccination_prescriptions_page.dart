import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/health_records/di/health_record_providers.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';
import 'package:petcare/features/health_records/domain/usecases/get_health_records_by_pet_usecase.dart';
import 'package:petcare/features/health_records/presentation/pages/vaccination_record_detail_page.dart';

class ProviderVaccinationPrescriptionsPage extends ConsumerStatefulWidget {
  const ProviderVaccinationPrescriptionsPage({super.key});

  @override
  ConsumerState<ProviderVaccinationPrescriptionsPage> createState() =>
      _ProviderVaccinationPrescriptionsPageState();
}

class _ProviderVaccinationPrescriptionsPageState
    extends ConsumerState<ProviderVaccinationPrescriptionsPage> {
  bool _isLoading = true;
  String? _error;
  List<_PrescriptionItem> _items = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrescriptions();
    });
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final session = ref.read(userSessionServiceProvider);
    final providerId = session.getUserId();
    if (providerId == null || providerId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Provider session not found.';
      });
      return;
    }

    await ref.read(providerBookingProvider.notifier).loadBookings();
    final bookingState = ref.read(providerBookingProvider);
    final bookings = bookingState.bookings.where((booking) {
      return (booking.petId ?? '').isNotEmpty;
    }).toList();

    if (bookings.isEmpty) {
      setState(() {
        _isLoading = false;
        _items = const [];
        _error = bookingState.error;
      });
      return;
    }

    final petIds = bookings
        .map((booking) => booking.petId)
        .whereType<String>()
        .where((petId) => petId.isNotEmpty)
        .toSet()
        .toList();

    final usecase = ref.read(getHealthRecordsByPetUsecaseProvider);
    final gathered = <_PrescriptionItem>[];
    String? firstFailure;

    for (final petId in petIds) {
      final result = await usecase(GetHealthRecordsByPetParams(petId: petId));
      result.fold(
        (failure) {
          firstFailure ??= failure.message;
        },
        (records) {
          for (final record in records) {
            if (!_isVaccinationRecord(record)) {
              continue;
            }

            final bookingContext = _findBestBookingForRecord(
              bookings: bookings,
              record: record,
              providerId: providerId,
            );

            if (record.prescribedByProviderId != null &&
                record.prescribedByProviderId!.isNotEmpty &&
                record.prescribedByProviderId != providerId) {
              continue;
            }

            if (bookingContext == null &&
                (record.prescribedByProviderId == null ||
                    record.prescribedByProviderId!.isEmpty)) {
              continue;
            }

            final ownerName =
                record.prescribedForUserName ??
                bookingContext?.userName ??
                bookingContext?.userId ??
                'Unknown user';
            final petName =
                bookingContext?.petName ?? record.petId ?? 'Unknown pet';
            final vetName =
                record.prescribedByProviderName ??
                bookingContext?.providerBusinessName ??
                session.getFirstName() ??
                'Vet';

            gathered.add(
              _PrescriptionItem(
                record: record,
                petName: petName,
                ownerName: ownerName,
                vetName: vetName,
              ),
            );
          }
        },
      );
    }

    gathered.sort((a, b) {
      final now = DateTime.now();
      final aDate = DateTime.tryParse(a.record.nextDueDate ?? '') ?? now;
      final bDate = DateTime.tryParse(b.record.nextDueDate ?? '') ?? now;
      return aDate.compareTo(bDate);
    });

    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
      _items = gathered;
      _error = gathered.isEmpty ? firstFailure : null;
    });
  }

  bool _isVaccinationRecord(HealthRecordEntity record) {
    final title = (record.title ?? '').toLowerCase();
    final type = (record.recordType ?? '').toLowerCase();
    final description = (record.description ?? '').toLowerCase();
    return title.contains('vacc') ||
        type.contains('vacc') ||
        description.contains('vacc');
  }

  BookingEntity? _findBestBookingForRecord({
    required List<BookingEntity> bookings,
    required HealthRecordEntity record,
    required String providerId,
  }) {
    final petId = record.petId;
    if (petId == null || petId.isEmpty) {
      return null;
    }

    final candidates = bookings.where((booking) {
      return booking.petId == petId &&
          booking.providerId == providerId &&
          (booking.status == 'confirmed' || booking.status == 'completed');
    }).toList();

    if (candidates.isEmpty) {
      return null;
    }

    final refDate =
        DateTime.tryParse(record.date ?? '') ??
        DateTime.tryParse(record.nextDueDate ?? '') ??
        DateTime.now();

    candidates.sort((a, b) {
      final aDate = DateTime.tryParse(a.startTime);
      final bDate = DateTime.tryParse(b.startTime);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      int score(DateTime date) {
        final diff = refDate.difference(date).inMinutes;
        if (diff >= 0) {
          return diff;
        }
        return diff.abs() + 1000000;
      }

      return score(aDate).compareTo(score(bDate));
    });
    return candidates.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Prescriptions')),
      body: RefreshIndicator(
        onRefresh: _loadPrescriptions,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 56,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _loadPrescriptions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.vaccines_rounded,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No vaccination prescriptions found yet.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final due = DateTime.tryParse(item.record.nextDueDate ?? '');
                  final dueText = due != null
                      ? DateFormat('MMM d, yyyy').format(due)
                      : 'Due soon';

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.vaccines_rounded),
                      ),
                      title: Text(item.record.title ?? 'Vaccination'),
                      subtitle: Text(
                        '${item.petName} | Owner: ${item.ownerName}\nNext due: $dueText',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VaccinationRecordDetailPage(
                              record: item.record,
                              petName: item.petName,
                              prescribedByName: item.vetName,
                              prescribedForUserName: item.ownerName,
                              resolveFromUserBookings: false,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PrescriptionItem {
  final HealthRecordEntity record;
  final String petName;
  final String ownerName;
  final String vetName;

  const _PrescriptionItem({
    required this.record,
    required this.petName,
    required this.ownerName,
    required this.vetName,
  });
}
