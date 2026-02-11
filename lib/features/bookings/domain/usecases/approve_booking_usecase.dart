import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';

class UpdateBookingStatusParams extends Equatable {
  final String bookingId;
  final String status;

  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}

class ApproveBookingUsecase
    implements UsecaseWithParams<BookingEntity, UpdateBookingStatusParams> {
  final IBookingRepository _repository;

  ApproveBookingUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, BookingEntity>> call(
    UpdateBookingStatusParams params,
  ) {
    return _repository.updateBookingStatus(params.bookingId, 'confirmed');
  }
}
