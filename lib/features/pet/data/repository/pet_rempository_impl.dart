import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/features/pet/data/datasource/pet_datasource.dart';
import 'package:petcare/features/pet/data/models/pet_api_model.dart';
import 'package:petcare/features/pet/data/models/pet_care_api_model.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class PetRepositoryImpl implements IPetRepository {
  final INetworkInfo _networkInfo;
  final IPetRemoteDataSource _remoteDataSource;

  PetRepositoryImpl({
    required INetworkInfo networkInfo,
    required IPetRemoteDataSource remoteDataSource,
  }) : _networkInfo = networkInfo,
       _remoteDataSource = remoteDataSource;

  @override
  Future<PetEntity> addPet(PetEntity pet) async {
    if (await _networkInfo.isConnected) {
      // Convert entity to API model
      final apiModel = PetApiModel.fromEntity(pet);

      // Call remote data source (image path is in imageUrl if local)
      final String? imagePath =
          (pet.imageUrl != null &&
              pet.imageUrl!.startsWith('/') &&
              !pet.imageUrl!.startsWith('/uploads'))
          ? pet.imageUrl
          : null;

      final createdPet = await _remoteDataSource.addPet(
        apiModel,
        imagePath: imagePath,
      );

      // Return the created pet as entity with generated ID
      return createdPet.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<PetEntity?> getPetById(String petId) async {
    if (await _networkInfo.isConnected) {
      final apiModel = await _remoteDataSource.getPetById(petId);
      return apiModel?.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<PetEntity>> getAllUserPets() async {
    if (await _networkInfo.isConnected) {
      final apiModels = await _remoteDataSource.getAllUserPets();
      return apiModels.map((model) => model.toEntity()).toList();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<PetEntity> updatePet(String petId, PetEntity pet) async {
    if (await _networkInfo.isConnected) {
      final apiModel = PetApiModel.fromEntity(pet);

      final String? imagePath =
          (pet.imageUrl != null &&
              pet.imageUrl!.startsWith('/') &&
              !pet.imageUrl!.startsWith('/uploads'))
          ? pet.imageUrl
          : null;

      final updatedPet = await _remoteDataSource.updatePet(
        petId,
        apiModel,
        imagePath: imagePath,
      );

      return updatedPet.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<PetCareEntity> getPetCare(String petId) async {
    if (await _networkInfo.isConnected) {
      final careModel = await _remoteDataSource.getPetCare(petId);
      return careModel.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<PetCareEntity> updatePetCare(String petId, PetCareEntity care) async {
    if (await _networkInfo.isConnected) {
      final careModel = PetCareApiModel.fromEntity(care);
      final updated = await _remoteDataSource.updatePetCare(petId, careModel);
      return updated.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<bool> deletePet(String petId) async {
    if (await _networkInfo.isConnected) {
      return await _remoteDataSource.deletePet(petId);
    } else {
      throw Exception('No internet connection');
    }
  }
}
