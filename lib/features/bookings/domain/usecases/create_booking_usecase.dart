import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';

class CreateBookingUsecase
    implements UsecaseWithParams<BookingEntity, BookingEntity> {
  final IBookingRepository _repository;

  CreateBookingUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, BookingEntity>> call(BookingEntity params) {
    return _repository.createBooking(params);
  }
}
