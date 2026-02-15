import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/pet/data/datasource/pet_datasource.dart';
import 'package:petcare/features/pet/data/models/pet_api_model.dart';

final petRemoteDatasourceProvider = Provider<IPetRemoteDataSource>((ref) {
  return PetRemoteDatabase(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class PetRemoteDatabase implements IPetRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  PetRemoteDatabase({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  @override
  Future<PetApiModel> addPet(PetApiModel pet, {String? imagePath}) async {
    FormData formData;

    if (imagePath != null) {
      // Multipart/form-data with image
      formData = FormData.fromMap({
        'name': pet.name,
        'species': pet.species,
        if (pet.breed != null && pet.breed!.isNotEmpty) 'breed': pet.breed,
        if (pet.age != null) 'age': pet.age.toString(),
        if (pet.weight != null) 'weight': pet.weight.toString(),
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
    } else {
      // JSON data only
      formData = FormData.fromMap(pet.toJsonForCreate());
    }

    final response = await _apiClient.post(
      ApiEndpoints.petCreate,
      data: formData,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid data format');
      }
      return PetApiModel.fromJson(data);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to add pet');
    }
  }

  @override
  Future<PetApiModel?> getPetById(String petId) async {
    final response = await _apiClient.get('${ApiEndpoints.petById}/$petId');

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        return null;
      }
      return PetApiModel.fromJson(data);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch pet');
    }
  }

  @override
  Future<List<PetApiModel>> getAllUserPets() async {
    if (!_sessionService.isLoggedIn()) {
      throw Exception('User not authenticated');
    }
    final response = await _apiClient.get(ApiEndpoints.petGetAll);

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! List) {
        return [];
      }
      return data
          .map((json) => PetApiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to fetch pets');
    }
  }

  @override
  Future<PetApiModel> updatePet(
    String petId,
    PetApiModel pet, {
    String? imagePath,
  }) async {
    FormData formData;

    if (imagePath != null) {
      formData = FormData.fromMap({
        if (pet.name.isNotEmpty) 'name': pet.name,
        if (pet.species.isNotEmpty) 'species': pet.species,
        if (pet.breed != null && pet.breed!.isNotEmpty) 'breed': pet.breed,
        if (pet.age != null) 'age': pet.age.toString(),
        if (pet.weight != null) 'weight': pet.weight.toString(),
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });
    } else {
      formData = FormData.fromMap(pet.toJsonForCreate());
    }

    final response = await _apiClient.put(
      '${ApiEndpoints.petUpdate}/$petId',
      data: formData,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid data format');
      }
      return PetApiModel.fromJson(data);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update pet');
    }
  }

  @override
  Future<bool> deletePet(String petId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.petDelete}/$petId',
    );

    if (response.data['success'] == true) {
      return true;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to delete pet');
    }
  }
}
