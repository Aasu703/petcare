import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/provider/data/datasource/provider_datasource.dart';
import 'package:petcare/features/provider/data/model/provider_api_model.dart';
import 'package:petcare/core/services/storage/token_service.dart';

// Provider for ProviderRemoteDatasource
final providerRemoteDatasourceProvider = Provider<IProviderRemoteDataSource>((
  ref,
) {
  return ProviderRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProviderRemoteDatasource implements IProviderRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;
  final TokenService _tokenService;

  ProviderRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService,
       _tokenService = tokenService;

  @override
  Future<List<ProviderApiModel>> getAllProviders() async {
    final response = await _apiClient.get(ApiEndpoints.providerGetAll);

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .map(
              (item) => ProviderApiModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    }
    return [];
  }

  @override
  Future<ProviderApiModel?> getProviderById(String providerId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.providerById}/$providerId', // Use the correct endpoint name
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return ProviderApiModel.fromJson(data);
      }
    }
    return null;
  }

  @override
  Future<ProviderApiModel> createProvider(ProviderApiModel provider) async {
    final response = await _apiClient.post(
      ApiEndpoints.providerCreate,
      data: provider.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return ProviderApiModel.fromJson(data);
      }
    }
    return provider;
  }

  @override
  Future<bool> updateProvider(ProviderApiModel provider) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.providerUpdate}/${provider.providerId}',
      data: provider.toJson(),
    );

    return response.data['success'] == true;
  }

  @override
  Future<bool> deleteProvider(String providerId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.providerDelete}/$providerId',
    );

    return response.data['success'] == true;
  }

  @override
  Future<ProviderApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.provider}/${ApiEndpoints.providerLogin}',
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      Map<String, dynamic>? providerJson;
      String? token;

      if (data is Map<String, dynamic>) {
        final nestedProvider = data['provider'];
        if (nestedProvider is Map<String, dynamic>) {
          providerJson = nestedProvider;
          token = (data['accessToken'] ?? response.data['token'])?.toString();
        } else {
          providerJson = data;
          token = response.data['token']?.toString();
        }
      }

      if (providerJson == null) {
        return null;
      }

      final provider = ProviderApiModel.fromJson(providerJson);

      // Save session
      await _sessionService.saveSession(
        userId: provider.providerId ?? '',
        firstName: provider.businessName,
        email: provider.email ?? email,
        lastName: '',
        role: 'provider',
        providerType: provider.providerType,
      );
      if (token is String && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      return provider;
    }
    return null;
  }

  @override
  Future<ProviderApiModel> register(ProviderApiModel provider) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.provider}/${ApiEndpoints.providerRegister}',
      data: provider.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        final nestedProvider = data['provider'];
        if (nestedProvider is Map<String, dynamic>) {
          return ProviderApiModel.fromJson(nestedProvider);
        }
        return ProviderApiModel.fromJson(data);
      }
    }
    return provider;
  }
}
