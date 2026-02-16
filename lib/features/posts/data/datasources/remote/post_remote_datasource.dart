import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/posts/data/models/post_model.dart';

abstract interface class IPostRemoteDataSource {
  Future<List<PostModel>> getAllPosts({int page = 1, int limit = 20});
  Future<PostModel> createPost(PostModel post);
  Future<List<PostModel>> getMyPosts();
  Future<PostModel?> getPostById(String postId);
  Future<PostModel> updatePost(String postId, PostModel post);
  Future<bool> deletePost(String postId);
}

final postRemoteDatasourceProvider = Provider<IPostRemoteDataSource>((ref) {
  return PostRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    sessionService: ref.read(userSessionServiceProvider),
  );
});

class PostRemoteDataSource implements IPostRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _sessionService;

  PostRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService sessionService,
  }) : _apiClient = apiClient,
       _sessionService = sessionService;

  @override
  Future<List<PostModel>> getAllPosts({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(
      ApiEndpoints.postAll,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    final response = await _apiClient.post(
      ApiEndpoints.postCreate,
      data: post.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final postData = data['data'] ?? data;
      if (postData is Map<String, dynamic>) {
        return PostModel.fromJson(postData);
      }
    }
    throw Exception('Failed to create post');
  }

  @override
  Future<List<PostModel>> getMyPosts() async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    final response = await _apiClient.get(ApiEndpoints.postMy);
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic>) {
      list = data['data'] ?? [];
    } else if (data is List) {
      list = data;
    }
    return list
        .map((item) => PostModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    final response = await _apiClient.get('${ApiEndpoints.postById}/$postId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final postData = data['data'] ?? data;
      if (postData is Map<String, dynamic>) {
        return PostModel.fromJson(postData);
      }
    }
    return null;
  }

  @override
  Future<PostModel> updatePost(String postId, PostModel post) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    final response = await _apiClient.put(
      '${ApiEndpoints.postById}/$postId',
      data: post.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final postData = data['data'] ?? data;
      if (postData is Map<String, dynamic>) {
        return PostModel.fromJson(postData);
      }
    }
    throw Exception('Failed to update post');
  }

  @override
  Future<bool> deletePost(String postId) async {
    if (!_sessionService.isLoggedIn() ||
        _sessionService.getRole() != 'provider') {
      throw Exception('Provider authentication required');
    }
    await _apiClient.delete('${ApiEndpoints.postById}/$postId');
    return true;
  }
}
