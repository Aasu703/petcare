import 'package:petcare/features/pet/data/models/pet_api_model.dart';
import 'package:petcare/features/pet/data/models/pet_care_api_model.dart';

abstract interface class IPetRemoteDataSource {
  Future<PetApiModel> addPet(PetApiModel pet, {String? imagePath});
  Future<PetApiModel?> getPetById(String petId);
  Future<List<PetApiModel>> getAllUserPets();
  Future<PetApiModel> updatePet(
    String petId,
    PetApiModel pet, {
    String? imagePath,
  });
  Future<PetApiModel> assignVet({required String petId, required String vetId});
  Future<List<PetApiModel>> getProviderAssignedPets();
  Future<List<Map<String, String>>> getVerifiedVets();
  Future<PetCareApiModel> getPetCare(String petId);
  Future<PetCareApiModel> updatePetCare(String petId, PetCareApiModel care);
  Future<bool> deletePet(String petId);
}
