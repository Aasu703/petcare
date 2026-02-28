import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/usecases/app_usecase.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';
import 'package:petcare/features/posts/domain/repositories/post_repository.dart';

class GetAllPostsParams extends Equatable {
  final int page;
  final int limit;

  const GetAllPostsParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class GetAllPostsUsecase
    implements UsecaseWithParams<List<PostEntity>, GetAllPostsParams> {
  final IPostRepository _repository;

  GetAllPostsUsecase({required IPostRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetAllPostsParams params) {
    return _repository.getAllPosts(page: params.page, limit: params.limit);
  }
}
