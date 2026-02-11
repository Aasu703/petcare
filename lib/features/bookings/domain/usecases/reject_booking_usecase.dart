import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';
import 'package:petcare/features/bookings/domain/usecases/approve_booking_usecase.dart';

class RejectBookingUsecase
    implements UsecaseWithParams<BookingEntity, UpdateBookingStatusParams> {
  final IBookingRepository _repository;

  RejectBookingUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdateBookingStatusParams params,
  ) {
    return _repository.updateBookingStatus(params.bookingId, 'cancelled');
  }
}
