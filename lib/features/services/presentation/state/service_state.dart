import 'package:petcare/features/services/domain/entities/service_entity.dart';

class ServiceState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;
  final List<ServiceEntity> services;

  const ServiceState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.services = const [],
  });

  ServiceState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    List<ServiceEntity>? services,
  }) {
    return ServiceState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
      services: services ?? this.services,
    );
  }
}
