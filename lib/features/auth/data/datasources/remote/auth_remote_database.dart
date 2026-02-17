import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/token_service.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';

// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    // Check if user is logged in before making the request
    if (!_sessionService.isLoggedIn()) {
      return null;
    }
    try {
      final response = await _apiClient.get(ApiEndpoints.userWhoAmI);

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is! Map<String, dynamic>) {
          return null;
        }
        return AuthApiModel.fromJSON(data);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    // Validate input parameters
    if (email.trim().isEmpty) {}

    if (password.trim().isEmpty) {}

    try {
      final requestData = {'email': email.trim(), 'password': password.trim()};

      // Explicitly encode as JSON to ensure proper serialization
      final jsonData = jsonEncode(requestData);

      final response = await _apiClient.post(
        ApiEndpoints.userLogin,
        data: jsonData, // Send as JSON string instead of Map
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        Map<String, dynamic>? userJson;
        String? token;

        if (data is Map<String, dynamic>) {
          final nestedUser = data['user'];
          if (nestedUser is Map<String, dynamic>) {
            userJson = nestedUser;
            token = (data['accessToken'] ?? response.data['token'])?.toString();
          } else {
            userJson = data;
            token = response.data['token']?.toString();
          }
        }

        if (userJson == null) {
          throw Exception('Invalid login payload received from server');
        }

        if (token == null || token.isEmpty) {
          throw Exception('Missing access token in login response');
        }

        final user = AuthApiModel.fromJSON(userJson);

        if (user.id == null || user.id!.isEmpty) {
          throw Exception('Invalid user ID received from server');
        }

        final safeFirstName = (user.Firstname?.isNotEmpty ?? false)
            ? user.Firstname!
            : (user.username?.isNotEmpty ?? false)
            ? user.username!
            : user.email.split('@').first;

        await _tokenService.saveToken(token);

        await _sessionService.saveSession(
          userId: user.id!,
          firstName: safeFirstName,
          email: user.email,
          lastName: '',
          role: 'user',
        );
        return user;
      } else {
        final errorMessage = response.data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.userRegister,
        data: user.toJSON(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          final registeredUser = AuthApiModel.fromJSON(data);
          return registeredUser;
        } else {
          throw Exception('Invalid registration data received');
        }
      } else {
        final errorMessage = response.data['message'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadPhoto(File photo) async {
    try {
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

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Upload failed');
      }

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Upload succeeded but no user payload was returned.');
      }

      final updatedUser = AuthApiModel.fromJSON(data);
      final avatar = updatedUser.avatar;
      if (avatar == null || avatar.isEmpty) {
        throw Exception('Upload succeeded but no avatar was returned.');
      }

      final userId = updatedUser.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('Upload succeeded but user identifier was missing.');
      }

      // Update session with new user data
      final safeFirstName = (updatedUser.Firstname?.isNotEmpty ?? false)
          ? updatedUser.Firstname!
          : (updatedUser.username?.isNotEmpty ?? false)
          ? updatedUser.username!
          : updatedUser.email.split('@').first;

      await _sessionService.saveSession(
        userId: userId,
        email: updatedUser.email,
        firstName: safeFirstName,
        lastName: '',
        role: _sessionService.getRole() ?? 'user',
      );

      return avatar;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Photo upload failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthApiModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    File? imageFile,
  }) async {
    try {
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

        final updatedUser = AuthApiModel.fromJSON(data);

        // Update session with new user data
        if (updatedUser.id != null && updatedUser.id!.isNotEmpty) {
          final safeFirstName = (updatedUser.Firstname?.isNotEmpty ?? false)
              ? updatedUser.Firstname!
              : (updatedUser.username?.isNotEmpty ?? false)
              ? updatedUser.username!
              : updatedUser.email.split('@').first;

          await _sessionService.saveSession(
            userId: updatedUser.id!,
            email: updatedUser.email,
            firstName: safeFirstName,
            lastName: '',
            role: _sessionService.getRole() ?? 'user',
          );
        }

        return updatedUser;
      }

      throw Exception(response.data['message'] ?? 'Failed to update profile');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
}
