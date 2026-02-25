import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Book Appointment'),
        backgroundColor: context.surfaceColor,
        foregroundColor: context.textPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            isPetLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<String>(
                    initialValue: selectedPetId,
                    items: pets
                        .map(
                          (pet) => DropdownMenuItem(
                            value: pet.petId,
                            child: Text('${pet.name} - ${pet.species}'),
                          ),
                        )
                        .toList(),
                    onChanged: onPetChanged,
                    decoration: InputDecoration(
                      hintText: pets.isEmpty ? 'No pets found' : 'Choose a pet',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Select Service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            isServiceLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<ServiceEntity>(
                    initialValue: selectedService,
                    items: services
                        .map(
                          (service) => DropdownMenuItem(
                            value: service,
                            child: Text(
                              '${service.title} - \$${service.price.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onServiceChanged,
                    decoration: InputDecoration(
                      hintText: services.isEmpty
                          ? 'No services available'
                          : 'Choose a service',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Select Provider',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            isProviderLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<String>(
                    initialValue: selectedProviderId,
                    items: providers
                        .map(
                          (provider) => DropdownMenuItem(
                            value: provider.providerId,
                            child: Text(provider.businessName),
                          ),
                        )
                        .toList(),
                    onChanged: onProviderChanged,
                    decoration: InputDecoration(
                      hintText: providers.isEmpty
                          ? 'No providers available'
                          : 'Choose a provider',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Select Date',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onPickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.iconPrimaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onPickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.iconPrimaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Duration',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [30, 60, 90, 120].map((minutes) {
                final isSelected = durationMinutes == minutes;
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: isSelected,
                  selectedColor: AppColors.iconPrimaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? context.textPrimary
                        : context.textSecondary,
                  ),
                  backgroundColor: context.surfaceColor,
                  onSelected: (_) => onDurationChanged(minutes),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Notes (optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Any special instructions...',
                hintStyle: TextStyle(color: context.hintColor),
                filled: true,
                fillColor: context.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (displayPrice != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${displayPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
