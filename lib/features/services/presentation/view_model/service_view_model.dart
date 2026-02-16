import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/services/di/service_providers.dart';
import 'package:petcare/features/services/domain/usecases/get_services_usecase.dart';
import 'package:petcare/features/services/presentation/state/service_state.dart';

class ServiceNotifier extends StateNotifier<ServiceState> {
  final Ref _ref;
  static const int _pageSize = 20;

  ServiceNotifier(this._ref) : super(const ServiceState());

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getServicesUsecaseProvider);
    final result = await usecase(GetServicesParams(page: 1, limit: _pageSize));
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (services) => state = state.copyWith(
        isLoading: false,
        services: services,
        page: 1,
        hasMore: services.length == _pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);
    final nextPage = state.page + 1;
    final usecase = _ref.read(getServicesUsecaseProvider);
    final result = await usecase(
      GetServicesParams(page: nextPage, limit: _pageSize),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingMore: false, error: failure.message),
      (services) => state = state.copyWith(
        isLoadingMore: false,
        services: [...state.services, ...services],
        page: nextPage,
        hasMore: services.length == _pageSize,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final serviceProvider = StateNotifierProvider<ServiceNotifier, ServiceState>(
  (ref) => ServiceNotifier(ref),
);
