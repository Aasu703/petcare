import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/services/notification/notification_service.dart';
import 'package:petcare/features/bookings/di/booking_providers.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/usecases/approve_booking_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/get_provider_bookings_usecase.dart';
import 'package:petcare/features/bookings/presentation/state/booking_state.dart';

// ======================== USER BOOKINGS ========================

class UserBookingNotifier extends StateNotifier<BookingState> {
  final Ref _ref;

  UserBookingNotifier(this._ref) : super(const BookingState());

  Future<void> loadBookings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getUserBookingsUsecaseProvider);
    final result = await usecase(GetUserBookingsParams(userId: userId));
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (bookings) =>
          state = state.copyWith(isLoading: false, bookings: bookings),
    );
  }

  Future<void> createBooking(BookingEntity booking) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(createBookingUsecaseProvider);
    final result = await usecase(booking);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (created) => state = state.copyWith(
        isLoading: false,
        createdBooking: created,
        bookings: [created, ...state.bookings],
      ),
    );
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final userBookingProvider =
    StateNotifierProvider<UserBookingNotifier, BookingState>((ref) {
      return UserBookingNotifier(ref);
    });

// ====================== PROVIDER BOOKINGS ======================

class ProviderBookingNotifier extends StateNotifier<BookingState> {
  final Ref _ref;

  ProviderBookingNotifier(this._ref) : super(const BookingState());

  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getProviderBookingsUsecaseProvider);
    final result = await usecase(const GetProviderBookingsParams());
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (bookings) =>
          state = state.copyWith(isLoading: false, bookings: bookings),
    );
  }

  Future<void> approveBooking(String bookingId) async {
    final usecase = _ref.read(approveBookingUsecaseProvider);
    final result = await usecase(
      UpdateBookingStatusParams(bookingId: bookingId, status: 'confirmed'),
    );
    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updated,
    ) {
      final updatedList = state.bookings.map((b) {
        return b.bookingId == bookingId ? updated : b;
      }).toList();
      state = state.copyWith(bookings: updatedList);

      // Schedule a push notification reminder 1 hour before the appointment
      final parsedTime = DateTime.tryParse(updated.startTime);
      if (parsedTime != null) {
        final notificationService = _ref.read(notificationServiceProvider);
        notificationService.scheduleBookingReminder(
          bookingNotificationId: NotificationService.bookingIdToNotificationId(
            updated.bookingId!,
          ),
          appointmentTime: parsedTime,
          title: 'Appointment Reminder',
          body: 'You have an upcoming appointment in 1 hour.',
        );
      }
    });
  }

  Future<void> rejectBooking(String bookingId) async {
    final usecase = _ref.read(rejectBookingUsecaseProvider);
    final result = await usecase(
      UpdateBookingStatusParams(bookingId: bookingId, status: 'cancelled'),
    );
    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updated,
    ) {
      final updatedList = state.bookings.map((b) {
        return b.bookingId == bookingId ? updated : b;
      }).toList();
      state = state.copyWith(bookings: updatedList);

      // Cancel the scheduled notification for this booking
      final notificationService = _ref.read(notificationServiceProvider);
      notificationService.cancelNotification(
        NotificationService.bookingIdToNotificationId(bookingId),
      );
    });
  }

  Future<void> completeBooking(String bookingId) async {
    final usecase = _ref.read(completeBookingUsecaseProvider);
    final result = await usecase(
      UpdateBookingStatusParams(bookingId: bookingId, status: 'completed'),
    );
    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updated,
    ) {
      final updatedList = state.bookings.map((b) {
        return b.bookingId == bookingId ? updated : b;
      }).toList();
      state = state.copyWith(bookings: updatedList);
    });
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final providerBookingProvider =
    StateNotifierProvider<ProviderBookingNotifier, BookingState>((ref) {
      return ProviderBookingNotifier(ref);
    });
