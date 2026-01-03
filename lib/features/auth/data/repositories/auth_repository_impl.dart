import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_hive_model.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:petcare/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource _dataSource;
  static String? _currentUserId;

  AuthRepositoryImpl({required IAuthDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      await _dataSource.register(model);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final model = await _dataSource.login(email, password);
      if (model == null) {
        return const Left(
          LocalDatabaseFailure(message: 'Invalid email or password'),
        );
      }
      _currentUserId = model.userId;
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      if (_currentUserId == null) {
        return const Left(LocalDatabaseFailure(message: 'No current user'));
      }
      final model = await _dataSource.getCurrentUser(_currentUserId!);
      if (model == null) {
        return const Left(LocalDatabaseFailure(message: 'User not found'));
      }
      return Right(model.toEntity());
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
      final result = await _dataSource.logout(_currentUserId!);
      if (result) {
        _currentUserId = null;
      }
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
