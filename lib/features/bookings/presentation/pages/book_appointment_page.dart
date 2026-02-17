import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/provider/presentation/view_model/provider_view_model.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';
import 'package:petcare/features/services/presentation/view_model/service_view_model.dart';

class BookAppointmentPage extends ConsumerStatefulWidget {
  final String? providerId;
  final String? serviceId;
  final String? petId;
  final double? price;

  const BookAppointmentPage({
    super.key,
    this.providerId,
    this.serviceId,
    this.petId,
    this.price,
  });

  @override
  ConsumerState<BookAppointmentPage> createState() =>
      _BookAppointmentPageState();
}

class _BookAppointmentPageState extends ConsumerState<BookAppointmentPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _durationMinutes = 30;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedPetId;
  String? _selectedProviderId;
  String? _selectedServiceId;
  ServiceEntity? _selectedService;
  bool _durationManuallySet = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.petId;
    _selectedProviderId = widget.providerId;
    _selectedServiceId = widget.serviceId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petNotifierProvider.notifier).getAllPets();
      ref.read(providerListProvider.notifier).loadProviders();
      ref.read(serviceProvider.notifier).loadServices();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitBooking() async {
    if (_selectedPetId == null || _selectedPetId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pet to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final providerId =
        _selectedProviderId ??
        _selectedService?.providerId ??
        widget.providerId;
    if (providerId == null || providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a provider to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final session = ref.read(userSessionServiceProvider);
    final userId = session.getUserId() ?? '';

    final startDT = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final endDT = startDT.add(Duration(minutes: _durationMinutes));

    final booking = BookingEntity(
      startTime: startDT.toIso8601String(),
      endTime: endDT.toIso8601String(),
      userId: userId,
      petId: _selectedPetId,
      providerId: providerId,
      serviceId: _selectedService?.serviceId ?? widget.serviceId,
      price: widget.price ?? _selectedService?.price,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(userBookingProvider.notifier).createBooking(booking);

    if (!mounted) return;
    final state = ref.read(userBookingProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context, true);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);
    final petState = ref.watch(petNotifierProvider);
    final providerState = ref.watch(providerListProvider);
    final serviceState = ref.watch(serviceProvider);
    final services = serviceState.services;
    final providers = providerState.providers;

    if (_selectedService == null && _selectedServiceId != null) {
      final match = services
          .where((s) => s.serviceId == _selectedServiceId)
          .toList();
      if (match.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedService = match.first;
            if (!_durationManuallySet &&
                _selectedService!.durationMinutes > 0) {
              _durationMinutes = _selectedService!.durationMinutes;
            }
            if (_selectedProviderId == null || _selectedProviderId!.isEmpty) {
              _selectedProviderId = _selectedService!.providerId;
            }
          });
        });
      }
    }

    final filteredProviders =
        (_selectedService?.providerId != null &&
            _selectedService!.providerId!.isNotEmpty)
        ? providers
              .where((p) => p.providerId == _selectedService!.providerId)
              .toList()
        : providers;

    final displayPrice = widget.price ?? _selectedService?.price;

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
            // Pet selector
            Text(
              'Select Pet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            petState.isLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<String>(
                    initialValue: _selectedPetId,
                    items: petState.pets
                        .map(
                          (pet) => DropdownMenuItem(
                            value: pet.petId,
                            child: Text('${pet.name} • ${pet.species}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPetId = value);
                    },
                    decoration: InputDecoration(
                      hintText: petState.pets.isEmpty
                          ? 'No pets found'
                          : 'Choose a pet',
                      filled: true,
                      fillColor: context.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            // Service selector
            Text(
              'Select Service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            serviceState.isLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<ServiceEntity>(
                    initialValue: _selectedService,
                    items: services
                        .map(
                          (service) => DropdownMenuItem(
                            value: service,
                            child: Text(
                              '${service.title} • \$${service.price.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedService = value;
                        _selectedServiceId = value?.serviceId;
                        if (!_durationManuallySet &&
                            (value?.durationMinutes ?? 0) > 0) {
                          _durationMinutes = value!.durationMinutes;
                        }
                        if (value?.providerId != null &&
                            value!.providerId!.isNotEmpty) {
                          _selectedProviderId = value.providerId;
                        }
                      });
                    },
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

            // Provider selector
            Text(
              'Select Provider',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            providerState.isLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : DropdownButtonFormField<String>(
                    initialValue: _selectedProviderId,
                    items: filteredProviders
                        .map(
                          (provider) => DropdownMenuItem(
                            value: provider.providerId,
                            child: Text(provider.businessName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedProviderId = value);
                    },
                    decoration: InputDecoration(
                      hintText: filteredProviders.isEmpty
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

            // Date picker
            Text(
              'Select Date',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
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

            // Time picker
            Text(
              'Select Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
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

            // Duration selector
            Text(
              'Duration',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [30, 60, 90, 120].map((min) {
                final isSelected = _durationMinutes == min;
                return ChoiceChip(
                  label: Text('$min min'),
                  selected: isSelected,
                  selectedColor: AppColors.iconPrimaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? context.textPrimary
                        : context.textSecondary,
                  ),
                  backgroundColor: context.surfaceColor,
                  onSelected: (_) => setState(() {
                    _durationMinutes = min;
                    _durationManuallySet = true;
                  }),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Notes
            Text(
              'Notes (optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
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
                      '\$${displayPrice.toStringAsFixed(2)}',
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

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
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
