import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/providers/session_provider.dart';

import 'package:petcare/core/services/session/session_service.dart';
import 'package:petcare/features/auth/data/datasources/auth_datasource.dart';
import 'package:petcare/features/auth/data/models/auth_api_model.dart';

// create a provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(sessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final SessionService _sessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required SessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );
    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        return null;
      }
      final user = AuthApiModel.fromJSON(data);
      final safeFirstName = (user.Firstname?.isNotEmpty ?? false)
          ? user.Firstname!
          : (user.username?.isNotEmpty ?? false)
          ? user.username!
          : user.email.split('@').first;

      // Saving the user session
      await _sessionService.saveSession(
        userId: user.id ?? '',
        firstName: safeFirstName,
        email: user.email,
      );
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
        final registerdUser = AuthApiModel.fromJSON(data);
        return registerdUser;
      }
    }
    return user;
  }
}
