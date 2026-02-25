import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/presentation/view_model/booking_view_model.dart';
import 'package:petcare/features/bookings/presentation/widgets/booking_history_widget.dart';

class BookingHistoryPage extends ConsumerStatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  ConsumerState<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends ConsumerState<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userSessionServiceProvider).getUserId() ?? '';
      ref.read(userBookingProvider.notifier).loadBookings(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userBookingProvider);
    final upcomingBookings = _sortBookings(
      state.bookings.where(_isUpcomingBooking).toList(),
    );
    final historyBookings = _sortBookings(
      state.bookings.where((booking) => !_isUpcomingBooking(booking)).toList(),
    );

    return BookingHistoryWidget(
      isLoading: state.isLoading,
      error: state.error,
      upcomingBookings: upcomingBookings,
      historyBookings: historyBookings,
      onReload: _reloadBookings,
    );
  }

  Future<void> _reloadBookings() async {
    final userId = ref.read(userSessionServiceProvider).getUserId() ?? '';
    await ref.read(userBookingProvider.notifier).loadBookings(userId);
  }

  List<BookingEntity> _sortBookings(List<BookingEntity> bookings) {
    final sorted = [...bookings];
    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(a.startTime);
      final bDate = DateTime.tryParse(b.startTime);
      if (aDate == null && bDate == null) {
        return 0;
      }
      if (aDate == null) {
        return 1;
      }
      if (bDate == null) {
        return -1;
      }
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  bool _isUpcomingBooking(BookingEntity booking) {
    final status = booking.status.toLowerCase();
    if (status == 'completed' || status == 'cancelled' || status == 'rejected') {
      return false;
    }
    if (status != 'pending' && status != 'confirmed') {
      return false;
    }

    final startDate = DateTime.tryParse(booking.startTime);
    if (startDate == null) {
      return true;
    }

    final now = DateTime.now();
    return startDate.isAfter(now);
  }
}
