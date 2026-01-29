import 'package:dio/dio.dart';
import 'package:petcare/features/pet/data/models/pet_api_model.dart';

abstract class PetRemoteDataSource {
  Future<List<PetApiModel>> getAllPets(String token);
  Future<PetApiModel> createPet({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  });
  Future<PetApiModel> getPetById(String token, String petId);
  Future<PetApiModel> updatePet({
    required String token,
    required String petId,
    String? name,
    String? species,
    String? breed,
    String? age,
    String? weight,
    String? imagePath,
  });
  Future<void> deletePet(String token, String petId);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final Dio _dio;
  final String baseUrl;

  PetRemoteDataSourceImpl({
    required Dio dio,
    this.baseUrl = 'http://10.0.2.2:5050/api', // Changed for Android Emulator
  }) : _dio = dio;

  @override
  Future<List<PetApiModel>> getAllPets(String token) async {
    try {
      print('🔑 Getting all pets with token: ${token.substring(0, 20)}...');
      
      final response = await _dio.get(
        '$baseUrl/pet',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('✅ Get pets response: ${response.data}');

      if (response.data['success'] == true) {
        List<dynamic> petsJson = response.data['data'];
        return petsJson.map((json) => PetApiModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load pets');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error fetching pets: $e');
    }
  }

  @override
  Future<PetApiModel> createPet({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  }) async {
    try {
      print('🔑 Token being sent: ${token.substring(0, 20)}...');
      print('📝 Pet data: name=$name, species=$species, breed=$breed, age=$age, weight=$weight');

      FormData formData = FormData.fromMap({
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'weight': weight,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
      });

      print('📤 Sending request to: $baseUrl/pet');

      final response = await _dio.post(
        '$baseUrl/pet',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.data['success'] == true) {
        return PetApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create pet');
      }
    } on DioException catch (e) {
      print('❌ DioException occurred');
      print('   Status code: ${e.response?.statusCode}');
      print('   Response data: ${e.response?.data}');
      print('   Message: ${e.message}');
      
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again. Token may be invalid or expired.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Bad request: ${e.response?.data['message'] ?? 'Invalid data'}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error creating pet: $e');
    }
  }

  @override
  Future<PetApiModel> getPetById(String token, String petId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/pet/$petId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return PetApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load pet');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching pet: $e');
    }
  }

  @override
  Future<PetApiModel> updatePet({
    required String token,
    required String petId,
    String? name,
    String? species,
    String? breed,
    String? age,
    String? weight,
    String? imagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        if (name != null) 'name': name,
        if (species != null) 'species': species,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
      });

      final response = await _dio.put(
        '$baseUrl/pet/$petId',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return PetApiModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update pet');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating pet: $e');
    }
  }

  @override
  Future<void> deletePet(String token, String petId) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/pet/$petId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete pet');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error deleting pet: $e');
    }
  }
}