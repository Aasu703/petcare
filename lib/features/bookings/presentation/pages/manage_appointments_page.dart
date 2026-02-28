import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';

class ManageAppointmentsPage extends ConsumerStatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  ConsumerState<ManageAppointmentsPage> createState() =>
      _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState
    extends ConsumerState<ManageAppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerBookingProvider.notifier).loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerBookingProvider);
    final filters = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Appointments'),
        backgroundColor: AppColors.iconPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter bar
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = state.selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter[0].toUpperCase() + filter.substring(1)),
                  selected: isSelected,
                  selectedColor: AppColors.iconPrimaryColor.withOpacity(0.2),
                  onSelected: (_) {
                    ref
                        .read(providerBookingProvider.notifier)
                        .setFilter(filter);
                  },
                );
              },
            ),
          ),
          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(state.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(providerBookingProvider.notifier)
                              .loadBookings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : state.filteredBookings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No appointments found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(providerBookingProvider.notifier)
                        .loadBookings(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = state.filteredBookings[index];
                        return _ProviderBookingCard(
                          booking: booking,
                          onApprove: booking.status == 'pending'
                              ? () => ref
                                    .read(providerBookingProvider.notifier)
                                    .approveBooking(booking.bookingId ?? '')
                              : null,
                          onReject: booking.status == 'pending'
                              ? () => ref
                                    .read(providerBookingProvider.notifier)
                                    .rejectBooking(booking.bookingId ?? '')
                              : null,
                          onComplete: booking.status == 'confirmed'
                              ? () => ref
                                    .read(providerBookingProvider.notifier)
                                    .completeBooking(booking.bookingId ?? '')
                              : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProviderBookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  const _ProviderBookingCard({
    required this.booking,
    this.onApprove,
    this.onReject,
    this.onComplete,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDT = DateTime.tryParse(booking.startTime);
    final dateStr = startDT != null
        ? DateFormat('EEE, MMM d, yyyy').format(startDT)
        : booking.startTime;
    final timeStr = startDT != null
        ? DateFormat('hh:mm a').format(startDT)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.event, color: _statusColor(booking.status)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dateStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status[0].toUpperCase() +
                        booking.status.substring(1),
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (timeStr.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(timeStr, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
            if (booking.price != null) ...[
              const SizedBox(height: 8),
              Text(
                '\$${booking.price!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.successColor,
                  fontSize: 15,
                ),
              ),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                booking.notes!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
            // Action buttons
            if (onApprove != null ||
                onReject != null ||
                onComplete != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null)
                    TextButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  if (onApprove != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                  if (onComplete != null)
                    ElevatedButton.icon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
