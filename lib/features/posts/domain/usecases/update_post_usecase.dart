import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';
import 'package:petcare/features/posts/domain/repositories/post_repository.dart';

class UpdatePostParams extends Equatable {
  final String postId;
  final PostEntity post;

  const UpdatePostParams({required this.postId, required this.post});

  @override
  List<Object?> get props => [postId, post];
}

class UpdatePostUsecase
    implements UsecaseWithParams<PostEntity, UpdatePostParams> {
  final IPostRepository _repository;

  UpdatePostUsecase({required IPostRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PostEntity>> call(UpdatePostParams params) {
    return _repository.updatePost(params.postId, params.post);
  }
}
