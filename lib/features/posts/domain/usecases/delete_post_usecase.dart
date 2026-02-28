import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/posts/domain/repositories/post_repository.dart';

class DeletePostUsecase implements UsecaseWithParams<bool, String> {
  final IPostRepository _repository;

  DeletePostUsecase({required IPostRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String postId) {
    return _repository.deletePost(postId);
  }
}
