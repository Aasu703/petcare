import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/provider_service/data/datasource/remote/provider_service_remote_datasource.dart';
import 'package:petcare/features/provider_service/data/repositories/provider_service_repository_impl.dart';
import 'package:petcare/features/provider_service/domain/repositories/provider_service_repository.dart';
import 'package:petcare/features/provider_service/domain/usecases/apply_provider_service_usecase.dart';
import 'package:petcare/features/provider_service/domain/usecases/get_my_provider_services_usecase.dart';
import 'package:petcare/features/provider_service/domain/usecases/get_provider_service_by_id_usecase.dart';

final providerServiceRepositoryProvider = Provider<IProviderServiceRepository>((
  ref,
) {
  final remote = ref.read(providerServiceRemoteDatasourceProvider);
  return ProviderServiceRepositoryImpl(remoteDataSource: remote);
});

final applyProviderServiceUsecaseProvider =
    Provider<ApplyProviderServiceUsecase>((ref) {
      final repo = ref.read(providerServiceRepositoryProvider);
      return ApplyProviderServiceUsecase(repository: repo);
    });

final getMyProviderServicesUsecaseProvider =
    Provider<GetMyProviderServicesUsecase>((ref) {
      final repo = ref.read(providerServiceRepositoryProvider);
      return GetMyProviderServicesUsecase(repository: repo);
    });

final getProviderServiceByIdUsecaseProvider =
    Provider<GetProviderServiceByIdUsecase>((ref) {
      final repo = ref.read(providerServiceRepositoryProvider);
      return GetProviderServiceByIdUsecase(repository: repo);
    });
