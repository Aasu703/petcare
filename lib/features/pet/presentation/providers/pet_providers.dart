import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecases/get_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:petcare/features/pet/data/repositories/pet_repository_provider.dart';

// Use case providers
final addPetUseCaseProvider = Provider<AddPetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return AddPetUseCase(repository);
});

final getPetsUseCaseProvider = Provider<GetPetsUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return GetPetsUseCase(repository);
});

final deletePetUseCaseProvider = Provider<DeletePetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return DeletePetUseCase(repository);
});

// Pet state management
class PetState {
  final List<PetEntity> pets;
  final bool isLoading;
  final String? error;

  PetState({this.pets = const [], this.isLoading = false, this.error});

  PetState copyWith({List<PetEntity>? pets, bool? isLoading, String? error}) {
    return PetState(
      pets: pets ?? this.pets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PetNotifier extends StateNotifier<PetState> {
  final GetPetsUseCase getPetsUseCase;
  final AddPetUseCase addPetUseCase;
  final DeletePetUseCase deletePetUseCase;

  PetNotifier({
    required this.getPetsUseCase,
    required this.addPetUseCase,
    required this.deletePetUseCase,
  }) : super(PetState());

  Future<void> loadPets(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pets = await getPetsUseCase(token);
      state = state.copyWith(pets: pets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPet({
    required String token,
    required String name,
    required String species,
    required String breed,
    required String age,
    required String weight,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPet = await addPetUseCase(
        token: token,
        name: name,
        species: species,
        breed: breed,
        age: age,
        weight: weight,
        imagePath: imagePath,
      );

      state = state.copyWith(pets: [...state.pets, newPet], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePet(String token, String petId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await deletePetUseCase(token, petId);

      state = state.copyWith(
        pets: state.pets.where((pet) => pet.id != petId).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final petNotifierProvider = StateNotifierProvider<PetNotifier, PetState>((ref) {
  return PetNotifier(
    getPetsUseCase: ref.watch(getPetsUseCaseProvider),
    addPetUseCase: ref.watch(addPetUseCaseProvider),
    deletePetUseCase: ref.watch(deletePetUseCaseProvider),
  );
});
