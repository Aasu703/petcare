import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:petcare/features/pet/data/repositories/pet_repository_provider.dart';

final addPetUseCaseProvider = Provider<AddPetUseCase>((ref) {
  final repository = ref.watch(petRepositoryProvider);
  return AddPetUseCase(repository);
});

final petListProvider = StateNotifierProvider<PetListNotifier, List<PetEntity>>(
  (ref) {
    // TODO: Replace with actual implementation using repository
    return PetListNotifier();
  },
);

class PetListNotifier extends StateNotifier<List<PetEntity>> {
  PetListNotifier() : super([]);

  void addPet(PetEntity pet) {
    state = [...state, pet];
  }

  // Optionally, add methods to fetch pets from repository
}
