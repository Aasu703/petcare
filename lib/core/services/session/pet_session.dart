import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/pet/domain/entities/pet_care_entity.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/usecase/addpet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/delete_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/get_all_pets_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/get_pet_care_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/update_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/update_pet_care_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/assign_vet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/get_provider_assigned_pets_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/get_verified_vets_usecase.dart';

// Pet State
class PetState {
  final bool isLoading;
  final List<PetEntity> pets;
  final String? error;
  final PetEntity? recentlyAddedPet; // For showing success message
  final PetCareEntity? activeCare;
  final List<Map<String, String>> verifiedVets;
  final List<PetEntity> assignedPets;

  const PetState({
    this.isLoading = false,
    this.pets = const [],
    this.error,
    this.recentlyAddedPet,
    this.activeCare,
    this.verifiedVets = const [],
    this.assignedPets = const [],
  });

  PetState copyWith({
    bool? isLoading,
    List<PetEntity>? pets,
    String? error,
    PetEntity? recentlyAddedPet,
    PetCareEntity? activeCare,
    List<Map<String, String>>? verifiedVets,
    List<PetEntity>? assignedPets,
    bool clearError = false,
    bool clearRecentPet = false,
    bool clearActiveCare = false,
  }) {
    return PetState(
      isLoading: isLoading ?? this.isLoading,
      pets: pets ?? this.pets,
      error: clearError ? null : (error ?? this.error),
      recentlyAddedPet: clearRecentPet
          ? null
          : (recentlyAddedPet ?? this.recentlyAddedPet),
      activeCare: clearActiveCare ? null : (activeCare ?? this.activeCare),
      verifiedVets: verifiedVets ?? this.verifiedVets,
      assignedPets: assignedPets ?? this.assignedPets,
    );
  }
}

// Pet Notifier
class PetNotifier extends StateNotifier<PetState> {
  final AddPetUsecase _addPetUsecase;
  final GetAllUserPetsUsecase _getAllPetsUsecase;
  final UpdatePetUsecase _updatePetUsecase;
  final DeletePetUsecase _deletePetUsecase;
  final GetPetCareUsecase _getPetCareUsecase;
  final UpdatePetCareUsecase _updatePetCareUsecase;
  final AssignVetUsecase _assignVetUsecase;
  final GetVerifiedVetsUsecase _getVerifiedVetsUsecase;
  final GetProviderAssignedPetsUsecase _getProviderAssignedPetsUsecase;

  PetNotifier({
    required AddPetUsecase addPetUsecase,
    required GetAllUserPetsUsecase getAllPetsUsecase,
    required UpdatePetUsecase updatePetUsecase,
    required DeletePetUsecase deletePetUsecase,
    required GetPetCareUsecase getPetCareUsecase,
    required UpdatePetCareUsecase updatePetCareUsecase,
    required AssignVetUsecase assignVetUsecase,
    required GetVerifiedVetsUsecase getVerifiedVetsUsecase,
    required GetProviderAssignedPetsUsecase getProviderAssignedPetsUsecase,
  }) : _addPetUsecase = addPetUsecase,
       _getAllPetsUsecase = getAllPetsUsecase,
       _updatePetUsecase = updatePetUsecase,
       _deletePetUsecase = deletePetUsecase,
       _getPetCareUsecase = getPetCareUsecase,
       _updatePetCareUsecase = updatePetCareUsecase,
       _assignVetUsecase = assignVetUsecase,
       _getVerifiedVetsUsecase = getVerifiedVetsUsecase,
       _getProviderAssignedPetsUsecase = getProviderAssignedPetsUsecase,
       super(const PetState());

  // Add a new pet
  Future<bool> addPet(AddPetUsecaseParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addPetUsecase.call(params);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (createdPet) {
        // Add the new pet to the list
        final updatedPets = [...state.pets, createdPet];
        state = state.copyWith(
          isLoading: false,
          pets: updatedPets,
          recentlyAddedPet: createdPet,
        );
        return true;
      },
    );
  }

  // Get all pets for current user
  Future<void> getAllPets() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllPetsUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pets) {
        state = state.copyWith(isLoading: false, pets: pets);
      },
    );
  }

  Future<bool> updatePet(UpdatePetParams params) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updatePetUsecase.call(params);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedPet) {
        final updatedList = state.pets
            .map((pet) => pet.petId == updatedPet.petId ? updatedPet : pet)
            .toList();
        state = state.copyWith(isLoading: false, pets: updatedList);
        return true;
      },
    );
  }

  Future<bool> deletePet(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deletePetUsecase.call(DeletePetParams(petId: petId));

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (deleted) {
        if (deleted) {
          final updatedList = state.pets
              .where((pet) => pet.petId != petId)
              .toList();
          state = state.copyWith(isLoading: false, pets: updatedList);
        } else {
          state = state.copyWith(isLoading: false);
        }
        return deleted;
      },
    );
  }

  Future<PetCareEntity?> getPetCare(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getPetCareUsecase.call(
      GetPetCareParams(petId: petId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (care) {
        state = state.copyWith(isLoading: false, activeCare: care);
        return care;
      },
    );
  }

  Future<bool> updatePetCare(String petId, PetCareEntity care) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updatePetCareUsecase.call(
      UpdatePetCareParams(petId: petId, care: care),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updated) {
        state = state.copyWith(isLoading: false, activeCare: updated);
        return true;
      },
    );
  }

  Future<bool> assignVet({required String petId, required String vetId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _assignVetUsecase(
      AssignVetParams(petId: petId, vetId: vetId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedPet) {
        final updatedList = state.pets
            .map((pet) => pet.petId == updatedPet.petId ? updatedPet : pet)
            .toList();
        state = state.copyWith(isLoading: false, pets: updatedList);
        return true;
      },
    );
  }

  Future<void> loadVerifiedVets() async {
    final result = await _getVerifiedVetsUsecase();
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (vets) => state = state.copyWith(verifiedVets: vets),
    );
  }

  Future<void> loadProviderAssignedPets() async {
    final result = await _getProviderAssignedPetsUsecase();
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (pets) => state = state.copyWith(assignedPets: pets),
    );
  }

  // Clear recent pet (after showing success message)
  void clearRecentPet() {
    state = state.copyWith(clearRecentPet: true);
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearActiveCare() {
    state = state.copyWith(clearActiveCare: true);
  }
}
