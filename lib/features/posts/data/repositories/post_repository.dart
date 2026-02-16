import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/error/failures.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:petcare/features/posts/data/mappers/post_mapper.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';
import 'package:petcare/features/posts/domain/repositories/post_repository.dart';

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  return PostRepository(
    remoteDataSource: ref.read(postRemoteDatasourceProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class PostRepository implements IPostRepository {
  final IPostRemoteDataSource _remoteDataSource;
  final UserSessionService _sessionService;

  PostRepository({
    required IPostRemoteDataSource remoteDataSource,
    required UserSessionService sessionService,
  }) : _remoteDataSource = remoteDataSource,
       _sessionService = sessionService;

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final posts = await _remoteDataSource.getAllPosts(
        page: page,
        limit: limit,
      );
      return Right(PostMapper.toEntityList(posts));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getMyPosts() async {
    try {
      if (!_sessionService.isLoggedIn() ||
          _sessionService.getRole() != 'provider') {
        return Left(ServerFailure(message: 'Provider authentication required'));
      }
      final posts = await _remoteDataSource.getMyPosts();
      return Right(PostMapper.toEntityList(posts));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(PostEntity post) async {
    try {
      if (!_sessionService.isLoggedIn() ||
          _sessionService.getRole() != 'provider') {
        return Left(ServerFailure(message: 'Provider authentication required'));
      }
      final postModel = PostMapper.toModel(post);
      final createdPost = await _remoteDataSource.createPost(postModel);
      return Right(PostMapper.toEntity(createdPost));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost(
    String postId,
    PostEntity post,
  ) async {
    // TODO: Implement update functionality in datasource
    return Left(ServerFailure(message: 'Update post not implemented yet'));
  }

  @override
  Future<Either<Failure, bool>> deletePost(String postId) async {
    // TODO: Implement delete functionality in datasource
    return Left(ServerFailure(message: 'Delete post not implemented yet'));
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    // TODO: Implement get by id functionality in datasource
    return Left(ServerFailure(message: 'Get post by id not implemented yet'));
  }
}
