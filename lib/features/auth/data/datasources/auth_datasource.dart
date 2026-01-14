import 'package:petcare/features/auth/data/models/auth_hive_model.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';

abstract interface class IAuthDataSource {
  Future<AuthHiveModel> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String userId);
  Future<bool> logout(String userId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}
