import 'package:petcare/core/services/hive/hive_service.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel model) async {
    return _hiveService.createUser(model);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser(String userId) {
    return _hiveService.getCurrentUser(userId);
  }

  @override
  Future<bool> logout(String userId) async {
    try {
      await _hiveService.logoutUser(userId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
