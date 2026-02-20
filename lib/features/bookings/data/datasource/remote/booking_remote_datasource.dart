import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
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

final bookingRemoteDatasourceProvider = Provider<IBookingRemoteDataSource>((
  ref,
) {
  return BookingRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class BookingRemoteDataSource implements IBookingRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  BookingRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  List<dynamic> _extractBookingsList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final directBookings = data['bookings'];
    if (directBookings is List) {
      return directBookings;
    }

    final inner = data['data'];
    if (inner is List) {
      return inner;
    }
    if (inner is Map<String, dynamic>) {
      final innerBookings = inner['bookings'];
      if (innerBookings is List) {
        return innerBookings;
      }
      final nestedData = inner['data'];
      if (nestedData is List) {
        return nestedData;
      }
    }

    return const [];
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookingCreate,
      data: booking.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Backend may wrap in { success, data } or return directly
      final bookingData = data['data'] ?? data;
      if (bookingData is Map<String, dynamic>) {
        return BookingModel.fromJson(bookingData);
      }
    }
    return booking;
  }

  @override
  Future<List<BookingModel>> getUserBookings(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.get(
      '${ApiEndpoints.bookingByUser}/$userId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final bookingsList = _extractBookingsList(response.data);
    return bookingsList
        .whereType<Map<String, dynamic>>()
        .map((item) => BookingModel.fromJson(item))
        .toList();
  }

  @override
  Future<List<BookingModel>> getProviderBookings({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.providerBookings,
      queryParameters: {'page': page, 'limit': limit},
    );
    final bookingsList = _extractBookingsList(response.data);
    return bookingsList
        .whereType<Map<String, dynamic>>()
        .map((item) => BookingModel.fromJson(item))
        .toList();
  }

  @override
  Future<BookingModel?> getBookingById(String bookingId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.bookingById}/$bookingId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final bookingData = data['data'] ?? data;
      if (bookingData is Map<String, dynamic>) {
        return BookingModel.fromJson(bookingData);
      }
    }
    return null;
  }

  @override
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.providerBookingStatus}/$bookingId/status',
      data: {'status': status},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final bookingData = data['data'] ?? data;
      if (bookingData is Map<String, dynamic>) {
        return BookingModel.fromJson(bookingData);
      }
    }
    throw Exception('Failed to update booking status');
  }

  @override
  Future<bool> deleteBooking(String bookingId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.bookingDelete}/$bookingId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['success'] == true;
    }
    return false;
  }
}
