import 'package:dio/dio.dart';
import 'package:petcare/features/pet/data/models/pet_api_model.dart';

abstract interface class IPetRemoteDataSource {
  Future<PetApiModel> addPet(PetApiModel pet, {String? imagePath});
  Future<PetApiModel?> getPetById(String petId);
  Future<List<PetApiModel>> getAllUserPets();
  Future<PetApiModel> updatePet(
    String petId,
    PetApiModel pet, {
    String? imagePath,
  });
  Future<bool> deletePet(String petId);
}
