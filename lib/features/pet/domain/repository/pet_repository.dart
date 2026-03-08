import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';

abstract interface class IPetRepository {
  /// Create a new pet and return the created pet with generated ID
  Future<PetEntity> addPet(PetEntity pet);

  /// Get a pet by its ID
  Future<PetEntity?> getPetById(String petId);

  /// Get all pets for the current user
  Future<List<PetEntity>> getAllUserPets();

  /// Update a pet
  Future<PetEntity> updatePet(String petId, PetEntity pet);

  /// Get care plan for a pet
  Future<PetCareEntity> getPetCare(String petId);

  /// Update care plan for a pet
  Future<PetCareEntity> updatePetCare(String petId, PetCareEntity care);

  /// Assign a vet to a pet
  Future<PetEntity> assignVet({required String petId, required String vetId});

  /// Providers: list pets assigned to them
  Future<List<PetEntity>> getProviderAssignedPets();

  /// Fetch verified vets for assignment
  Future<List<Map<String, String>>> getVerifiedVets();

  /// Delete a pet
  Future<bool> deletePet(String petId);
}
