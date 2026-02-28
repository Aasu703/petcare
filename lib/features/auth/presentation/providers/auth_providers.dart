import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/core_providers.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/datasources/remote/auth_remote_database.dart';
import 'package:petcare/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:petcare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';
import 'package:petcare/features/auth/domain/usecases/login_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/register_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/update_profile_usecase.dart';

// Data source
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hive = ref.read(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hive);
});

final authRemoteDatasourceDIProvider = Provider<IAuthRemoteDataSource>((ref) {
  return ref.read(authRemoteDatasourceProvider);
});

// Repository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final local = ref.read(authLocalDatasourceProvider);
  final remote = ref.read(authRemoteDatasourceDIProvider);
  final net = ref.read(iNetworkInfoProvider);
  return AuthRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
    networkInfo: net,
  );
});

// Usecases
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginUsecase(repository: repo);
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterUsecase(repository: repo);
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(repository: repo);
});

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(repository: repo);
});
