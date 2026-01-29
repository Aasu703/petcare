import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

abstract class PetRepository {
  Future<List<PetEntity>> getPets(String token);
  Future<PetEntity> getPetById(String token, String petId);
  Future<PetEntity> addPet({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  });
  Future<PetEntity> updatePet({
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
