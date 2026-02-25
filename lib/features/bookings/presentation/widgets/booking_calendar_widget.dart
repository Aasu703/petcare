import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingCalendarWidget extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<BookingEntity> selectedEvents;
  final List<BookingEntity> Function(DateTime day) eventLoader;
  final void Function(DateTime selectedDay, DateTime focusedDay)
  onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  const BookingCalendarWidget({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.selectedEvents,
    required this.eventLoader,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Calendar'),
        backgroundColor: AppColors.iconPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<BookingEntity>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: focusedDay,
            calendarFormat: calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: eventLoader,
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            onPageChanged: onPageChanged,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.iconPrimaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.iconPrimaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.successColor,
                shape: BoxShape.circle,
              ),
              markerSize: 6,
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      selectedDay != null
                          ? 'No bookings on this day'
                          : 'Select a date to view bookings',
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final booking = selectedEvents[index];
                      return _CalendarBookingTile(booking: booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarBookingTile extends StatelessWidget {
  final BookingEntity booking;

  const _CalendarBookingTile({required this.booking});

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
    final timeStr = startDT != null ? DateFormat('hh:mm a').format(startDT) : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(booking.status).withOpacity(0.15),
          child: Icon(Icons.event, color: _statusColor(booking.status), size: 20),
        ),
        title: Text(
          timeStr.isNotEmpty ? timeStr : 'Appointment',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          booking.status[0].toUpperCase() + booking.status.substring(1),
          style: TextStyle(color: _statusColor(booking.status), fontSize: 13),
        ),
        trailing: booking.price != null
            ? Text(
                '\$${booking.price!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.successColor,
                ),
              )
            : null,
      ),
    );
  }
}
