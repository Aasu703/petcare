import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/providers/session_providers.dart';
import 'package:petcare/core/providers/token_service.dart';
import 'package:petcare/core/services/session/session_service.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';

// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(sessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final SessionService _sessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required SessionService sessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(ApiEndpoints.userWhoAmI);

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        return null;
      }
      return AuthApiModel.fromJSON(data);
    }

    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final token = response.data['token']; // Extract token from response

      if (data is! Map<String, dynamic>) {
        return null;
      }

      final user = AuthApiModel.fromJSON(data);

      final safeFirstName = (user.Firstname?.isNotEmpty ?? false)
          ? user.Firstname!
          : (user.username?.isNotEmpty ?? false)
          ? user.username!
          : user.email.split('@').first;

      // Save session with token
      await _sessionService.saveSession(
        userId: user.id ?? '',
        firstName: safeFirstName,
        email: user.email,
        token: token, // Save the JWT token
      );
      if (token is String && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJSON(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        final registeredUser = AuthApiModel.fromJSON(data);
        return registeredUser;
      }
    }

    return user;
  }

  @override
  Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(photo.path, filename: fileName),
    });
    // Get token from token service
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing authentication token. Please login again.');
    }

    final response = await _apiClient.put(
      ApiEndpoints.userUploadPhoto,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Upload succeeded but no user payload was returned.');
    }

    final updatedUser = AuthApiModel.fromJSON(data);
    final avatar = updatedUser.avatar;
    if (avatar == null || avatar.isEmpty) {
      throw Exception('Upload succeeded but no profilePic was returned.');
    }

    final userId = updatedUser.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('Upload succeeded but user identifier was missing.');
    }

    await _sessionService.saveSession(
      userId: userId,
      email: updatedUser.email,
      firstName: '',
    );

    return avatar;
  }

  @override
  Future<AuthApiModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    File? imageFile,
  }) async {
    // Get token from token service
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing authentication token. Please login again.');
    }

    final formData = FormData.fromMap({
      if (firstName != null && firstName.trim().isNotEmpty)
        'Firstname': firstName.trim(),
      if (lastName != null && lastName.trim().isNotEmpty)
        'Lastname': lastName.trim(),
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone': phoneNumber.trim(),
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    final response = await _apiClient.put(
      ApiEndpoints.userUploadPhoto,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid profile payload');
      }
      return AuthApiModel.fromJSON(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update profile');
  }
}
