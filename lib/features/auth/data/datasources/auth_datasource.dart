import 'dart:io';

import 'package:petcare/features/auth/data/models/auth_hive_model.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';

abstract interface class IAuthDataSource {
  Future<AuthHiveModel> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser(String userId);
  Future<String> uploadPhoto(File photo);
  Future<bool> logout(String userId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<String> uploadPhoto(File photo);
  Future<AuthApiModel?> getUserById(String authId);
  Future<AuthApiModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    File? imageFile,
  });
}
