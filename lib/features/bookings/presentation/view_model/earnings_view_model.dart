import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/bookings/di/booking_providers.dart';
import 'package:petcare/features/bookings/domain/entities/earnings_entity.dart';
import 'package:petcare/features/bookings/domain/usecases/get_provider_earnings_usecase.dart';

class EarningsState {
  final bool isLoading;
  final String? error;
  final EarningsEntity? earnings;

  const EarningsState({this.isLoading = false, this.error, this.earnings});

  EarningsState copyWith({
    bool? isLoading,
    String? error,
    EarningsEntity? earnings,
  }) {
    return EarningsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      earnings: earnings ?? this.earnings,
    );
  }
}

class EarningsNotifier extends StateNotifier<EarningsState> {
  final GetProviderEarningsUsecase _usecase;

  EarningsNotifier(this._usecase) : super(const EarningsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _usecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (earnings) =>
          state = state.copyWith(isLoading: false, earnings: earnings),
    );
  }
}

final getProviderEarningsUsecaseProvider = Provider<GetProviderEarningsUsecase>(
  (ref) {
    final repo = ref.read(bookingRepositoryProvider);
    return GetProviderEarningsUsecase(repository: repo);
  },
);

final earningsProvider = StateNotifierProvider<EarningsNotifier, EarningsState>(
  (ref) {
    final usecase = ref.read(getProviderEarningsUsecaseProvider);
    return EarningsNotifier(usecase);
  },
);
