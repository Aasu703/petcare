import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/pet/domain/repository/pet_repository.dart';

class GetVerifiedVetsUsecase
    implements UsecaseWithoutParams<List<Map<String, String>>> {
  final IPetRepository _repository;

  GetVerifiedVetsUsecase({required IPetRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<Map<String, String>>>> call() async {
    try {
      final vets = await _repository.getVerifiedVets();
      return Right(vets);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
