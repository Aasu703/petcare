import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';

class BookingCalendarPage extends ConsumerStatefulWidget {
  const BookingCalendarPage({super.key});

  @override
  ConsumerState<BookingCalendarPage> createState() =>
      _BookingCalendarPageState();
}

class _BookingCalendarPageState extends ConsumerState<BookingCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userSessionServiceProvider).getUserId() ?? '';
      ref.read(userBookingProvider.notifier).loadBookings(userId);
    });
  }

  List<BookingEntity> _getEventsForDay(
    DateTime day,
    List<BookingEntity> bookings,
  ) {
    return bookings.where((b) {
      final dt = DateTime.tryParse(b.startTime);
      if (dt == null) return false;
      return isSameDay(dt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userBookingProvider);
    final bookings = state.bookings;
    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, bookings)
        : <BookingEntity>[];

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
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(day, bookings),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
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
          // Selected day's bookings
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      _selectedDay != null
                          ? 'No bookings on this day'
                          : 'Select a date to view bookings',
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final b = selectedEvents[index];
                      return _CalendarBookingTile(booking: b);
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
    final timeStr = startDT != null
        ? DateFormat('hh:mm a').format(startDT)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(booking.status).withOpacity(0.15),
          child: Icon(
            Icons.event,
            color: _statusColor(booking.status),
            size: 20,
          ),
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
