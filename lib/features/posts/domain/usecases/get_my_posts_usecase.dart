import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';
import 'package:petcare/features/posts/domain/repositories/post_repository.dart';

class GetMyPostsUsecase implements UsecaseWithoutParams<List<PostEntity>> {
  final IPostRepository _repository;

  GetMyPostsUsecase({required IPostRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<PostEntity>>> call() {
    return _repository.getMyPosts();
  }
}
