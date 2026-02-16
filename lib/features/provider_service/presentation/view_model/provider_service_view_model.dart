import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/provider_service/di/provider_service_providers.dart';
import 'package:petcare/features/provider_service/domain/entities/provider_service_entity.dart';
import 'package:petcare/features/provider_service/domain/usecases/apply_provider_service_usecase.dart';
import 'package:petcare/features/provider_service/presentation/state/provider_service_state.dart';

class ProviderServiceNotifier extends StateNotifier<ProviderServiceState> {
  final Ref _ref;

  ProviderServiceNotifier(this._ref) : super(const ProviderServiceState());

  Future<void> loadMyServices() async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(getMyProviderServicesUsecaseProvider);
    final result = await usecase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (services) =>
          state = state.copyWith(isLoading: false, services: services),
    );
  }

  Future<void> applyForService(
    ProviderServiceEntity entity, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths = const [],
    String? businessRegistrationPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final usecase = _ref.read(applyProviderServiceUsecaseProvider);
    final result = await usecase(
      ApplyProviderServiceParams(
        entity: entity,
        medicalLicensePath: medicalLicensePath,
        certificationPath: certificationPath,
        facilityImagePaths: facilityImagePaths,
        businessRegistrationPath: businessRegistrationPath,
      ),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (applied) => state = state.copyWith(
        isLoading: false,
        lastApplied: applied,
        services: [applied, ...state.services],
      ),
    );
  }
}

final providerServiceProvider =
    StateNotifierProvider<ProviderServiceNotifier, ProviderServiceState>((ref) {
      return ProviderServiceNotifier(ref);
    });
