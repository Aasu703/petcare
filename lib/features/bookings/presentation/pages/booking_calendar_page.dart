import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/bookings/presentation/widgets/booking_calendar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

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
    return bookings.where((booking) {
      final dt = DateTime.tryParse(booking.startTime);
      if (dt == null) {
        return false;
      }
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

    return BookingCalendarWidget(
      calendarFormat: _calendarFormat,
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      selectedEvents: selectedEvents,
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
    );
  }
}
