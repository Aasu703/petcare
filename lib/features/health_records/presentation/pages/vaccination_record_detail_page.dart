import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';
import 'package:petcare/features/provider/presentation/view_model/provider_view_model.dart';

class VaccinationRecordDetailPage extends ConsumerStatefulWidget {
  final HealthRecordEntity record;
  final String petName;
  final String? prescribedByName;
  final String? prescribedForUserName;
  final bool resolveFromUserBookings;

  const VaccinationRecordDetailPage({
    super.key,
    required this.record,
    required this.petName,
    this.prescribedByName,
    this.prescribedForUserName,
    this.resolveFromUserBookings = true,
  });

  @override
  ConsumerState<VaccinationRecordDetailPage> createState() =>
      _VaccinationRecordDetailPageState();
}

class _VaccinationRecordDetailPageState
    extends ConsumerState<VaccinationRecordDetailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.resolveFromUserBookings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadContextData();
      });
    }
  }

  Future<void> _loadContextData() async {
    final session = ref.read(userSessionServiceProvider);
    final userId = session.getUserId();
    if (userId != null && userId.isNotEmpty) {
      await ref.read(userBookingProvider.notifier).loadBookings(userId);
    }
    await ref.read(providerListProvider.notifier).loadProviders();
  }

  BookingEntity? _findBestRelatedBooking(List<BookingEntity> bookings) {
    final petId = widget.record.petId;
    if (petId == null || petId.isEmpty) {
      return null;
    }

    final candidates = bookings.where((booking) {
      final matchesPet = booking.petId == petId;
      final isRelevantStatus =
          booking.status == 'confirmed' ||
          booking.status == 'completed' ||
          booking.status == 'pending';
      return matchesPet && isRelevantStatus;
    }).toList();

    if (candidates.isEmpty) {
      return null;
    }

    final refDate =
        DateTime.tryParse(widget.record.date ?? '') ??
        DateTime.tryParse(widget.record.nextDueDate ?? '') ??
        DateTime.now();

    candidates.sort((a, b) {
      final aDate = DateTime.tryParse(a.startTime);
      final bDate = DateTime.tryParse(b.startTime);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      int score(DateTime date) {
        final diffMinutes = refDate.difference(date).inMinutes;
        if (diffMinutes >= 0) {
          return diffMinutes;
        }
        return diffMinutes.abs() + 1000000;
      }

      return score(aDate).compareTo(score(bDate));
    });

    return candidates.first;
  }

  @override
  Widget build(BuildContext context) {
    final providerState = ref.watch(providerListProvider);
    final bookingState = widget.resolveFromUserBookings
        ? ref.watch(userBookingProvider)
        : null;

    final relatedBooking = widget.resolveFromUserBookings
        ? _findBestRelatedBooking(bookingState?.bookings ?? const [])
        : null;

    String resolveVetName() {
      final preferred =
          widget.prescribedByName ??
          widget.record.prescribedByProviderName ??
          relatedBooking?.providerBusinessName;
      if (preferred != null && preferred.trim().isNotEmpty) {
        return preferred.trim();
      }

      final providerId =
          widget.record.prescribedByProviderId ?? relatedBooking?.providerId;
      if (providerId != null && providerId.isNotEmpty) {
        final match = providerState.providers.where((provider) {
          return provider.providerId == providerId;
        }).toList();
        if (match.isNotEmpty) {
          return match.first.businessName;
        }
      }

      return 'Unknown vet';
    }

    String resolveOwnerName() {
      final preferred =
          widget.prescribedForUserName ??
          widget.record.prescribedForUserName ??
          relatedBooking?.userName;
      if (preferred != null && preferred.trim().isNotEmpty) {
        return preferred.trim();
      }

      final session = ref.read(userSessionServiceProvider);
      final firstName = session.getFirstName();
      final lastName = session.getLastName();
      if (firstName != null && firstName.isNotEmpty) {
        final fullName = [
          firstName,
          lastName ?? '',
        ].where((part) => part.trim().isNotEmpty).join(' ').trim();
        if (fullName.isNotEmpty) {
          return fullName;
        }
      }
      return 'Unknown user';
    }

    final dueDate = DateTime.tryParse(widget.record.nextDueDate ?? '');
    final issuedDate = DateTime.tryParse(widget.record.date ?? '');
    final dueDateText = dueDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(dueDate)
        : 'Not set';
    final issuedDateText = issuedDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(issuedDate)
        : 'Not set';

    final isResolvingContext =
        widget.resolveFromUserBookings &&
        ((bookingState?.isLoading ?? false) || providerState.isLoading);

    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isResolvingContext) const LinearProgressIndicator(minHeight: 2),
          if (isResolvingContext) const SizedBox(height: 12),
          _DetailCard(
            title: widget.record.title ?? 'Vaccination',
            subtitle: widget.record.recordType ?? 'Health record',
            icon: Icons.vaccines_rounded,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.pets_rounded,
            label: 'Pet',
            value: widget.petName.isEmpty ? 'Unknown pet' : widget.petName,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.local_hospital_rounded,
            label: 'Prescribed By',
            value: resolveVetName(),
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.person_rounded,
            label: 'Prescribed For',
            value: resolveOwnerName(),
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.event_note_rounded,
            label: 'Issued Date',
            value: issuedDateText,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.event_available_rounded,
            label: 'Next Due',
            value: dueDateText,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'Description',
            value: (widget.record.description ?? '').trim().isEmpty
                ? 'No additional notes'
                : widget.record.description!.trim(),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DetailCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 24, child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
