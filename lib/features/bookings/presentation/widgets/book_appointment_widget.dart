import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_dropdown_section.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_date_time_section.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_duration_section.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_notes_section.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_price_summary.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment/booking_submit_button.dart';

class BookAppointmentWidget extends StatelessWidget {
  final bool isPetLoading;
  final List<PetEntity> pets;
  final String? selectedPetId;
  final ValueChanged<String?> onPetChanged;
  final bool isServiceLoading;
  final List<ServiceEntity> services;
  final ServiceEntity? selectedService;
  final ValueChanged<ServiceEntity?> onServiceChanged;
  final bool isProviderLoading;
  final List<ProviderEntity> providers;
  final String? selectedProviderId;
  final ValueChanged<String?> onProviderChanged;
  final String dateStr;
  final String timeStr;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final int durationMinutes;
  final ValueChanged<int> onDurationChanged;
  final TextEditingController notesController;
  final double? displayPrice;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const BookAppointmentWidget({
    super.key,
    required this.isPetLoading,
    required this.pets,
    required this.selectedPetId,
    required this.onPetChanged,
    required this.isServiceLoading,
    required this.services,
    required this.selectedService,
    required this.onServiceChanged,
    required this.isProviderLoading,
    required this.providers,
    required this.selectedProviderId,
    required this.onProviderChanged,
    required this.dateStr,
    required this.timeStr,
    required this.onPickDate,
    required this.onPickTime,
    required this.durationMinutes,
    required this.onDurationChanged,
    required this.notesController,
    required this.displayPrice,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.tr('bookAppointment')),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingDropdownSection(
              isPetLoading: isPetLoading,
              pets: pets,
              selectedPetId: selectedPetId,
              onPetChanged: onPetChanged,
              isServiceLoading: isServiceLoading,
              services: services,
              selectedService: selectedService,
              onServiceChanged: onServiceChanged,
              isProviderLoading: isProviderLoading,
              providers: providers,
              selectedProviderId: selectedProviderId,
              onProviderChanged: onProviderChanged,
            ),
            const SizedBox(height: 20),
            BookingDateTimeSection(
              dateStr: dateStr,
              timeStr: timeStr,
              onPickDate: onPickDate,
              onPickTime: onPickTime,
            ),
            const SizedBox(height: 20),
            BookingDurationSection(
              durationMinutes: durationMinutes,
              onDurationChanged: onDurationChanged,
            ),
            const SizedBox(height: 20),
            BookingNotesSection(notesController: notesController),
            if (displayPrice != null) ...[
              const SizedBox(height: 20),
              BookingPriceSummary(displayPrice: displayPrice!),
            ],
            const SizedBox(height: 32),
            BookingSubmitButton(isSubmitting: isSubmitting, onSubmit: onSubmit),
          ],
        ),
      ),
    );
  }
}
