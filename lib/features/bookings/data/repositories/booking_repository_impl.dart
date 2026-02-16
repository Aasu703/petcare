import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/bookings/data/datasource/remote/booking_remote_datasource.dart';
import 'package:petcare/features/bookings/data/models/booking_model.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final IBookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl({required IBookingRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BookingEntity>> createBooking(
    BookingEntity booking,
  ) async {
    try {
      final model = BookingModel.fromEntity(booking);
      final result = await _remoteDataSource.createBooking(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getUserBookings(
        userId,
        page: page,
        limit: limit,
      );
      return Right(BookingModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getProviderBookings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getProviderBookings(
        page: page,
        limit: limit,
      );
      return Right(BookingModel.toEntityList(models));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    try {
      final model = await _remoteDataSource.getBookingById(bookingId);
      if (model == null) {
        return const Left(ServerFailure(message: 'Booking not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final model = await _remoteDataSource.updateBookingStatus(
        bookingId,
        status,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBooking(String bookingId) async {
    try {
      final result = await _remoteDataSource.deleteBooking(bookingId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
