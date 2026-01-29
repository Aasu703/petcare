import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repositories/pet_repository.dart';
import 'package:petcare/features/pet/data/datasource/remote/pet_remote_datasource.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PetEntity>> getPets(String token) async {
    try {
      final petModels = await remoteDataSource.getAllPets(token);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pets: $e');
    }
  }

  @override
  Future<PetEntity> getPetById(String token, String petId) async {
    try {
      final petModel = await remoteDataSource.getPetById(token, petId);
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get pet: $e');
    }
  }

  @override
  Future<PetEntity> addPet({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  }) async {
    try {
      final petModel = await remoteDataSource.createPet(
        token: token,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        imagePath: imagePath,
      );
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to add pet: $e');
    }
  }

  @override
  Future<PetEntity> updatePet({
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
      final petModel = await remoteDataSource.updatePet(
        token: token,
        petId: petId,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        imagePath: imagePath,
      );
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  @override
  Future<void> deletePet(String token, String petId) async {
    try {
      await remoteDataSource.deletePet(token, petId);
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }
}
