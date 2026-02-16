import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/bookings/domain/entities/earnings_entity.dart';
import 'package:petcare/features/bookings/domain/repositories/booking_repository.dart';
import 'package:intl/intl.dart';

/// Calculates provider earnings from completed bookings.
/// Pure domain logic — no dependency on external services.
class GetProviderEarningsUsecase
    implements UsecaseWithoutParams<EarningsEntity> {
  final IBookingRepository _repository;

  GetProviderEarningsUsecase({required IBookingRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, EarningsEntity>> call() async {
    final result = await _repository.getProviderBookings(page: 1, limit: 500);
    return result.fold((failure) => Left(failure), (bookings) {
      final completed = bookings.where((b) => b.status == 'completed').toList();

      final totalEarnings = _sum(completed);
      final monthlyEarnings = _sumForCurrentMonth(completed);
      final dailyEarnings = _groupByDay(completed);

      return Right(
        EarningsEntity(
          totalEarnings: totalEarnings,
          monthlyEarnings: monthlyEarnings,
          completedAppointments: completed.length,
          dailyEarnings: dailyEarnings,
        ),
      );
    });
  }

  double _sum(List<BookingEntity> bookings) {
    return bookings.fold(0.0, (sum, b) => sum + (b.price ?? 0));
  }

  double _sumForCurrentMonth(List<BookingEntity> bookings) {
    final now = DateTime.now();
    return bookings.fold(0.0, (sum, b) {
      final dt = DateTime.tryParse(b.startTime);
      if (dt != null && dt.year == now.year && dt.month == now.month) {
        return sum + (b.price ?? 0);
      }
      return sum;
    });
  }

  Map<String, double> _groupByDay(List<BookingEntity> bookings) {
    final map = <String, double>{};
    final formatter = DateFormat('yyyy-MM-dd');
    for (final b in bookings) {
      final dt = DateTime.tryParse(b.startTime);
      if (dt == null) continue;
      final key = formatter.format(dt);
      map[key] = (map[key] ?? 0) + (b.price ?? 0);
    }
    return map;
  }
}
