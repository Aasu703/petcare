import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/provider_service/data/models/provider_service_model.dart';

abstract interface class IProviderServiceRemoteDataSource {
  Future<ProviderServiceModel> applyForService(
    ProviderServiceModel model, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths,
    String? businessRegistrationPath,
  });
  Future<List<ProviderServiceModel>> getMyServices();
  Future<ProviderServiceModel?> getServiceById(String serviceId);
}

final providerServiceRemoteDatasourceProvider =
    Provider<IProviderServiceRemoteDataSource>((ref) {
      return ProviderServiceRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class ProviderServiceRemoteDataSource
    implements IProviderServiceRemoteDataSource {
  final ApiClient _apiClient;

  ProviderServiceRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<ProviderServiceModel> applyForService(
    ProviderServiceModel model, {
    String? medicalLicensePath,
    String? certificationPath,
    List<String> facilityImagePaths = const [],
    String? businessRegistrationPath,
  }) async {
    final formMap = <String, dynamic>{...model.toJsonForApply()};

    if (medicalLicensePath != null) {
      formMap['medicalLicenseDocument'] = await MultipartFile.fromFile(
        medicalLicensePath,
        filename: medicalLicensePath.split('/').last,
      );
    }

    if (certificationPath != null) {
      formMap['certificationDocument'] = await MultipartFile.fromFile(
        certificationPath,
        filename: certificationPath.split('/').last,
      );
    }

    if (facilityImagePaths.isNotEmpty) {
      formMap['facilityImages'] = await Future.wait(
        facilityImagePaths.map(
          (path) async =>
              MultipartFile.fromFile(path, filename: path.split('/').last),
        ),
      );
    }

    if (businessRegistrationPath != null) {
      formMap['businessRegistrationDocument'] = await MultipartFile.fromFile(
        businessRegistrationPath,
        filename: businessRegistrationPath.split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.providerServiceApply,
      data: FormData.fromMap(formMap),
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return ProviderServiceModel.fromJson(inner);
      }
    }

    throw Exception('Failed to apply for service');
  }

  @override
  Future<List<ProviderServiceModel>> getMyServices() async {
    final response = await _apiClient.get(ApiEndpoints.providerServiceMy);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? data['services'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map(
          (item) => ProviderServiceModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<ProviderServiceModel?> getServiceById(String serviceId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.providerServiceById}/$serviceId',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data;
      if (inner is Map<String, dynamic>) {
        return ProviderServiceModel.fromJson(inner);
      }
    }
    return null;
  }
}
