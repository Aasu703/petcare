import 'package:petcare/features/provider/domain/entities/provider_entity.dart';

class ProviderState {
  final bool isLoading;
  final String? error;
  final List<ProviderEntity> providers;

  const ProviderState({
    this.isLoading = false,
    this.error,
    this.providers = const [],
  });

  ProviderState copyWith({
    bool? isLoading,
    String? error,
    List<ProviderEntity>? providers,
  }) {
    return ProviderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      providers: providers ?? this.providers,
    );
  }
}
