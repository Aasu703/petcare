import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:petcare/core/services/connectivity/network_info.dart';
import 'package:petcare/core/services/session/pet_session.dart';

import 'package:petcare/features/pet/data/datasource/remote/pet_remote_database.dart';

import 'package:petcare/features/pet/data/repository/pet_rempository_impl.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';
import 'package:petcare/features/pet/domain/usecase/addpet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/delete_pet_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/get_all_pets_usecase.dart';
import 'package:petcare/features/pet/domain/usecase/update_pet_usecase.dart';

// Repository Provider
final petRepositoryProvider = Provider<IPetRepository>((ref) {
  return PetRepositoryImpl(
    networkInfo: ref.read(networkInfoProvider),
    remoteDataSource: ref.read(petRemoteDatasourceProvider),
  );
});

// Use Case Providers
final addPetUsecaseProvider = Provider<AddPetUsecase>((ref) {
  return AddPetUsecase(repository: ref.read(petRepositoryProvider));
});

final getAllPetsUsecaseProvider = Provider<GetAllUserPetsUsecase>((ref) {
  return GetAllUserPetsUsecase(repository: ref.read(petRepositoryProvider));
});

final updatePetUsecaseProvider = Provider<UpdatePetUsecase>((ref) {
  return UpdatePetUsecase(repository: ref.read(petRepositoryProvider));
});

final deletePetUsecaseProvider = Provider<DeletePetUsecase>((ref) {
  return DeletePetUsecase(repository: ref.read(petRepositoryProvider));
});

// State Notifier Provider
final petNotifierProvider = StateNotifierProvider<PetNotifier, PetState>((ref) {
  return PetNotifier(
    addPetUsecase: ref.read(addPetUsecaseProvider),
    getAllPetsUsecase: ref.read(getAllPetsUsecaseProvider),
    updatePetUsecase: ref.read(updatePetUsecaseProvider),
    deletePetUsecase: ref.read(deletePetUsecaseProvider),
  );
});
