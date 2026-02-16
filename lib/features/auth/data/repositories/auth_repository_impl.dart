import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';
import 'package:petcare/features/auth/data/models/auth_hive_model.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource _localDataSource;
  final IAuthRemoteDataSource _remoteDataSource;
  final INetworkInfo _networkInfo;
  static String? _currentUserId;

  AuthRepositoryImpl({
    required IAuthDataSource localDataSource,
    required IAuthRemoteDataSource remoteDataSource,
    required INetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(
    AuthEntity entity,
    String confirmPassword,
  ) async {
    try {
      if (await _networkInfo.isConnected) {
        // Online: use remote API
        final apiModel = AuthApiModel.fromEntity(entity);
        // Create a new model with confirmPassword for API request
        final apiModelWithConfirm = AuthApiModel(
          id: apiModel.id,
          Firstname: apiModel.Firstname,
          Lastname: apiModel.Lastname,
          email: apiModel.email,
          phoneNumber: apiModel.phoneNumber,
          username: apiModel.username,
          password: apiModel.password,
          confirmPassword: confirmPassword,
          avatar: apiModel.avatar,
        );
        await _remoteDataSource.register(apiModelWithConfirm);
        return const Right(true);
      } else {
        // Offline: fallback to local Hive
        final model = AuthHiveModel.fromEntity(entity);
        await _localDataSource.register(model);
        return const Right(true);
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    print('🏗️ REPOSITORY LOGIN: Starting repository login for email: $email');

    try {
      final isConnected = await _networkInfo.isConnected;
      print('🌐 REPOSITORY NETWORK: Network connection status: $isConnected');

      if (isConnected) {
        // Online: use remote API
        print('🌐 REPOSITORY: Using remote API for login');
        final apiModel = await _remoteDataSource.login(email, password);

        if (apiModel == null) {
          print('❌ REPOSITORY LOGIN: Remote login returned null user');
          return const Left(
            LocalDatabaseFailure(message: 'Invalid email or password'),
          );
        }

        _currentUserId = apiModel.id ?? '';
        print('✅ REPOSITORY LOGIN: Login successful, user ID: $_currentUserId');

        final entity = apiModel.toEntity();
        print('🔄 REPOSITORY LOGIN: Converted to entity: ${entity.email}');
        return Right(entity);
      } else {
        // Offline: fallback to local Hive
        print('💾 REPOSITORY: Network unavailable, using local storage');
        final model = await _localDataSource.login(email, password);

        if (model == null) {
          print('❌ REPOSITORY LOGIN: Local login returned null user');
          return const Left(
            LocalDatabaseFailure(message: 'Invalid email or password'),
          );
        }

        _currentUserId = model.userId;
        print(
          '✅ REPOSITORY LOGIN: Local login successful, user ID: $_currentUserId',
        );

        final entity = model.toEntity();
        print('🔄 REPOSITORY LOGIN: Converted to entity: ${entity.email}');
        return Right(entity);
      }
    } catch (e) {
      print('💥 REPOSITORY LOGIN EXCEPTION: ${e.toString()}');
      print('🔍 REPOSITORY EXCEPTION TYPE: ${e.runtimeType}');
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      if (await _networkInfo.isConnected) {
        final apiModel = await _remoteDataSource.getUserById(
          _currentUserId ?? '',
        );
        if (apiModel == null) {
          return const Left(LocalDatabaseFailure(message: 'User not found'));
        }
        return Right(apiModel.toEntity());
      } else {
        if (_currentUserId == null) {
          return const Left(LocalDatabaseFailure(message: 'No current user'));
        }
        final model = await _localDataSource.getCurrentUser(_currentUserId!);
        if (model == null) {
          return const Left(LocalDatabaseFailure(message: 'User not found'));
        }
        return Right(model.toEntity());
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      if (_currentUserId == null) {
        return const Right(false);
      }
      if (await _networkInfo.isConnected) {
        // Remote logout not implemented; clear local state
        _currentUserId = null;
        return const Right(true);
      } else {
        final result = await _localDataSource.logout(_currentUserId!);
        if (result) {
          _currentUserId = null;
        }
        return Right(result);
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    File? imageFile,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final updated = await _remoteDataSource.updateProfile(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          imageFile: imageFile,
        );

        return Right(updated.toEntity());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
