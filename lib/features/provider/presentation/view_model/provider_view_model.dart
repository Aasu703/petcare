import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/provider/di/provider_providers.dart';
import 'package:petcare/features/provider/presentation/state/provider_state.dart';

class ProviderNotifier extends StateNotifier<ProviderState> {
  final Ref _ref;

  ProviderNotifier(this._ref) : super(const ProviderState());

  Future<void> loadProviders() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getAllProviderUsecaseProvider);
    final result = await usecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (providers) =>
          state = state.copyWith(isLoading: false, providers: providers),
    );
  }
}

final providerListProvider =
    StateNotifierProvider<ProviderNotifier, ProviderState>(
      (ref) => ProviderNotifier(ref),
    );
