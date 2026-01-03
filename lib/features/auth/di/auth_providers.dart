import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/hive/hive_service.dart';
import 'package:petcare/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:petcare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';
import 'package:petcare/features/auth/domain/usecases/login_usecase.dart';
import 'package:petcare/features/auth/domain/usecases/register_usecase.dart';

// Core
final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

// Data source
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hive = ref.read(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hive);
});

// Repository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final ds = ref.read(authLocalDatasourceProvider);
  return AuthRepositoryImpl(dataSource: ds);
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
