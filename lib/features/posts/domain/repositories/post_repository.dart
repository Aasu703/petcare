import 'package:dartz/dartz.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';

abstract interface class IPostRepository {
  Future<Either<Failure, List<PostEntity>>> getAllPosts({
    int page = 1,
    int limit = 20,
  });
  Future<Either<Failure, List<PostEntity>>> getMyPosts();
  Future<Either<Failure, PostEntity>> createPost(PostEntity post);
  Future<Either<Failure, PostEntity>> updatePost(
    String postId,
    PostEntity post,
  );
  Future<Either<Failure, bool>> deletePost(String postId);
  Future<Either<Failure, PostEntity>> getPostById(String postId);
}
