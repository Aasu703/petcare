import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

abstract interface class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking);
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId, {
    int page,
    int limit,
  });
  Future<Either<Failure, List<BookingEntity>>> getProviderBookings({
    int page,
    int limit,
  });
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status,
  );
  Future<Either<Failure, bool>> deleteBooking(String bookingId);
}
