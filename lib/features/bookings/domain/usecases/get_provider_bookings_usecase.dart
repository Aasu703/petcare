import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';

class GetProviderBookingsParams extends Equatable {
  final int page;
  final int limit;

  const GetProviderBookingsParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class GetProviderBookingsUsecase
    implements
        UsecaseWithParams<List<BookingEntity>, GetProviderBookingsParams> {
  final IBookingRepository _repository;

  GetProviderBookingsUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    GetProviderBookingsParams params,
  ) {
    return _repository.getProviderBookings(
      page: params.page,
      limit: params.limit,
    );
  }
}
