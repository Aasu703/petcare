import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';

class GetUserBookingsParams extends Equatable {
  final String userId;
  final int page;
  final int limit;

  const GetUserBookingsParams({
    required this.userId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

class GetUserBookingsUsecase
    implements UsecaseWithParams<List<BookingEntity>, GetUserBookingsParams> {
  final IBookingRepository _repository;

  GetUserBookingsUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    GetUserBookingsParams params,
  ) {
    return _repository.getUserBookings(
      params.userId,
      page: params.page,
      limit: params.limit,
    );
  }
}
