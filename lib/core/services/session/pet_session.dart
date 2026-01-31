import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecases/get_all_pets.dart';
import 'package:petcare/features/pet/domain/usecases/update_pet_usecase.dart';

// Pet State
class PetState {
  final bool isLoading;
  final List<PetEntity> pets;
  final String? error;
  final PetEntity? recentlyAddedPet; // For showing success message

  const PetState({
    this.isLoading = false,
    this.pets = const [],
    this.error,
    this.recentlyAddedPet,
  });

  PetState copyWith({
    bool? isLoading,
    List<PetEntity>? pets,
    String? error,
    PetEntity? recentlyAddedPet,
    bool clearError = false,
    bool clearRecentPet = false,
  }) {
    return PetState(
      isLoading: isLoading ?? this.isLoading,
      pets: pets ?? this.pets,
      error: clearError ? null : (error ?? this.error),
      recentlyAddedPet: clearRecentPet
          ? null
          : (recentlyAddedPet ?? this.recentlyAddedPet),
    );
  }
}

// Pet Notifier
class PetNotifier extends StateNotifier<PetState> {
  final AddPetUsecase _addPetUsecase;
  final GetAllUserPetsUsecase _getAllPetsUsecase;
  final UpdatePetUsecase _updatePetUsecase;
  final DeletePetUsecase _deletePetUsecase;

  PetNotifier({
    required AddPetUsecase addPetUsecase,
    required GetAllUserPetsUsecase getAllPetsUsecase,
    required UpdatePetUsecase updatePetUsecase,
    required DeletePetUsecase deletePetUsecase,
  }) : _addPetUsecase = addPetUsecase,
       _getAllPetsUsecase = getAllPetsUsecase,
       _updatePetUsecase = updatePetUsecase,
       _deletePetUsecase = deletePetUsecase,
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

  // Clear recent pet (after showing success message)
  void clearRecentPet() {
    state = state.copyWith(clearRecentPet: true);
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
