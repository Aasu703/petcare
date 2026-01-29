import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/pet/data/datasource/remote/pet_remote_datasource.dart';
import 'package:petcare/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:petcare/features/pet/domain/repositories/pet_repository.dart';

// Dio provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptors for logging if needed
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});

// Remote data source provider
final petRemoteDataSourceProvider = Provider<PetRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PetRemoteDataSourceImpl(
    dio: dio,
    baseUrl: 'http://10.0.2.2:5050/api', // For Android emulator
    // baseUrl: 'http://localhost:5050/api', // For iOS simulator
    // baseUrl: 'http://YOUR_IP:5050/api', // For physical device
  );
});

// Pet repository provider
final petRepositoryProvider = Provider<PetRepository>((ref) {
  final remoteDataSource = ref.watch(petRemoteDataSourceProvider);
  return PetRepositoryImpl(remoteDataSource: remoteDataSource);
});
