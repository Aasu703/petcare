import 'package:petcare/features/bookings/data/models/booking_model.dart';

abstract interface class IBookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<List<BookingModel>> getUserBookings(
    String userId, {
    int page,
    int limit,
  });
  Future<List<BookingModel>> getProviderBookings({int page, int limit});
  Future<BookingModel?> getBookingById(String bookingId);
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<bool> deleteBooking(String bookingId);
}
