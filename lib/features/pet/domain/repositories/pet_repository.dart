import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

abstract interface class IPetRepository {
  /// Create a new pet and return the created pet with generated ID
  Future<PetEntity> addPet(PetEntity pet);

  /// Get a pet by its ID
  Future<PetEntity?> getPetById(String petId);

  /// Get all pets for the current user
  Future<List<PetEntity>> getAllUserPets();

  /// Update a pet
  Future<PetEntity> updatePet(String petId, PetEntity pet);

  /// Delete a pet
  Future<bool> deletePet(String petId);
}
