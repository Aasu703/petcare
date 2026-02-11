import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/bookings/data/datasource/remote/booking_remote_datasource.dart';
import 'package:petcare/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';
import 'package:petcare/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/get_user_bookings_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/get_provider_bookings_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/approve_booking_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/reject_booking_usecase.dart';
import 'package:petcare/features/bookings/domain/usecases/complete_booking_usecase.dart';

// Repository
final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  final remote = ref.read(bookingRemoteDatasourceProvider);
  return BookingRepositoryImpl(remoteDataSource: remote);
});

// Usecases
final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  final repo = ref.read(bookingRepositoryProvider);
  return CreateBookingUsecase(repository: repo);
});

final getUserBookingsUsecaseProvider = Provider<GetUserBookingsUsecase>((ref) {
  final repo = ref.read(bookingRepositoryProvider);
  return GetUserBookingsUsecase(repository: repo);
});

final getProviderBookingsUsecaseProvider = Provider<GetProviderBookingsUsecase>(
  (ref) {
    final repo = ref.read(bookingRepositoryProvider);
    return GetProviderBookingsUsecase(repository: repo);
  },
);

final approveBookingUsecaseProvider = Provider<ApproveBookingUsecase>((ref) {
  final repo = ref.read(bookingRepositoryProvider);
  return ApproveBookingUsecase(repository: repo);
});

final rejectBookingUsecaseProvider = Provider<RejectBookingUsecase>((ref) {
  final repo = ref.read(bookingRepositoryProvider);
  return RejectBookingUsecase(repository: repo);
});

final completeBookingUsecaseProvider = Provider<CompleteBookingUsecase>((ref) {
  final repo = ref.read(bookingRepositoryProvider);
  return CompleteBookingUsecase(repository: repo);
});
