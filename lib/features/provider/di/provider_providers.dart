import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/hive/hive_service.dart';
import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/features/provider/data/datasource/provider_datasource.dart';
import 'package:petcare/features/provider/data/datasource/remote/provider_remote_datasource.dart';
import 'package:petcare/features/provider/data/datasource/local/provider_local_datasource.dart';
import 'package:petcare/features/provider/data/repository/provider_repository.dart';
import 'package:petcare/features/provider/domain/repository/provider_repository.dart';
import 'package:petcare/features/provider/domain/usecases/create_provider_usecase.dart';
import 'package:petcare/features/provider/domain/usecases/delete_provider_usecase.dart';
import 'package:petcare/features/provider/domain/usecases/get_all_provider_usecase.dart';
import 'package:petcare/features/provider/domain/usecases/get_provider_usecase.dart';
import 'package:petcare/features/provider/domain/usecases/update_provider_usercase.dart';

// Core
final hiveServiceProviderDI = Provider<HiveService>((ref) => HiveService());

final networkInfoProviderDI = Provider<INetworkInfo>(
  (ref) => ref.read(networkInfoProvider),
);

// Data sources
final providerLocalDatasourceProvider = Provider<IProviderDatasource>((ref) {
  final hive = ref.read(hiveServiceProviderDI);
  return ProviderLocalDatasource(hiveService: hive);
});

final providerRemoteDatasourceDIProvider = Provider<IProviderRemoteDataSource>((
  ref,
) {
  return ref.read(providerRemoteDatasourceProvider);
});

// Repository
final providerRepositoryProvider = Provider<IProviderRepository>((ref) {
  final local = ref.read(providerLocalDatasourceProvider);
  final remote = ref.read(providerRemoteDatasourceDIProvider);
  final net = ref.read(networkInfoProviderDI);
  return ProviderRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
    networkInfo: net,
  );
});

// Usecases
final createProviderUsecaseProvider = Provider<CreateProviderUsecase>((ref) {
  final repo = ref.read(providerRepositoryProvider);
  return CreateProviderUsecase(repository: repo);
});

final deleteProviderUsecaseProvider = Provider<DeleteProviderUsecase>((ref) {
  final repo = ref.read(providerRepositoryProvider);
  return DeleteProviderUsecase(repository: repo);
});

final getAllProviderUsecaseProvider = Provider<GetAllProviderUsecase>((ref) {
  final repo = ref.read(providerRepositoryProvider);
  return GetAllProviderUsecase(repository: repo);
});

final getProviderUsecaseProvider = Provider<GetProviderUsecase>((ref) {
  final repo = ref.read(providerRepositoryProvider);
  return GetProviderUsecase(repository: repo);
});

final updateProviderUsecaseProvider = Provider<UpdateProviderUsecase>((ref) {
  final repo = ref.read(providerRepositoryProvider);
  return UpdateProviderUsecase(repository: repo);
});
