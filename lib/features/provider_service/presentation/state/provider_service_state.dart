import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/core/state/base_state.dart';

class ProviderServiceState extends BaseState {
  final List<ProviderServiceEntity> services;
  final ProviderServiceEntity? lastApplied;

  const ProviderServiceState({
    bool isLoading = false,
    String? error,
    this.services = const [],
    this.lastApplied,
  }) : super(isLoading: isLoading, error: error);

  ProviderServiceState copyWith({
    bool? isLoading,
    String? error,
    List<ProviderServiceEntity>? services,
    ProviderServiceEntity? lastApplied,
  }) {
    return ProviderServiceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      services: services ?? this.services,
      lastApplied: lastApplied ?? this.lastApplied,
    );
  }
}
