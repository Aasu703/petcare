import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/posts/data/datasources/remote/post_remote_datasource.dart';
import 'package:petcare/features/posts/data/models/post_model.dart';

abstract interface class IPostRepository {
  Future<PostModel> createPost(PostModel post);
  Future<List<PostModel>> getMyPosts();
  Future<PostModel?> getPostById(String postId);
  Future<PostModel> updatePost(String postId, PostModel post);
  Future<bool> deletePost(String postId);
}

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
  Future<PostModel> createPost(PostModel post) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    return await _remoteDataSource.createPost(post);
  }

  @override
  Future<List<PostModel>> getMyPosts() async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    return await _remoteDataSource.getMyPosts();
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    return await _remoteDataSource.getPostById(postId);
  }

  @override
  Future<PostModel> updatePost(String postId, PostModel post) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    return await _remoteDataSource.updatePost(postId, post);
  }

  @override
  Future<bool> deletePost(String postId) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    return await _remoteDataSource.deletePost(postId);
  }
}
