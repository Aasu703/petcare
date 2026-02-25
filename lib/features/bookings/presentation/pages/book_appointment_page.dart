import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/bookings/presentation/widgets/book_appointment_widget.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
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
        _selectedProviderId ?? _selectedService?.providerId ?? widget.providerId;
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

    if (!mounted) {
      return;
    }
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
    final providers = providerState.providers
        .where((provider) => (provider.providerId ?? '').isNotEmpty)
        .toList();

    if (_selectedService == null && _selectedServiceId != null) {
      final match = services.where((service) => service.serviceId == _selectedServiceId);
      if (match.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _selectedService = match.first;
            if (!_durationManuallySet && _selectedService!.durationMinutes > 0) {
              _durationMinutes = _selectedService!.durationMinutes;
            }
            if (_selectedProviderId == null || _selectedProviderId!.isEmpty) {
              _selectedProviderId = _selectedService!.providerId;
            }
          });
        });
      }
    }

    final hasSelectedProviderInList = providers.any(
      (provider) => provider.providerId == _selectedProviderId,
    );
    final dropdownSelectedProvider = hasSelectedProviderInList
        ? _selectedProviderId
        : null;
    final displayPrice = widget.price ?? _selectedService?.price;

    return BookAppointmentWidget(
      isPetLoading: petState.isLoading,
      pets: petState.pets,
      selectedPetId: _selectedPetId,
      onPetChanged: (value) {
        setState(() => _selectedPetId = value);
      },
      isServiceLoading: serviceState.isLoading,
      services: services,
      selectedService: _selectedService,
      onServiceChanged: (value) {
        setState(() {
          _selectedService = value;
          _selectedServiceId = value?.serviceId;
          if (!_durationManuallySet && (value?.durationMinutes ?? 0) > 0) {
            _durationMinutes = value!.durationMinutes;
          }
          if (value?.providerId != null && value!.providerId!.isNotEmpty) {
            _selectedProviderId = value.providerId;
          }
        });
      },
      isProviderLoading: providerState.isLoading,
      providers: providers,
      selectedProviderId: dropdownSelectedProvider,
      onProviderChanged: (value) {
        setState(() => _selectedProviderId = value);
      },
      dateStr: dateStr,
      timeStr: timeStr,
      onPickDate: _pickDate,
      onPickTime: _pickTime,
      durationMinutes: _durationMinutes,
      onDurationChanged: (minutes) {
        setState(() {
          _durationMinutes = minutes;
          _durationManuallySet = true;
        });
      },
      notesController: _notesController,
      displayPrice: displayPrice,
      isSubmitting: _isSubmitting,
      onSubmit: _submitBooking,
    );
  }
}
