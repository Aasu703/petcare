import 'package:petcare/features/posts/data/models/post_model.dart';

abstract interface class IPostRemoteDataSource {
  Future<List<PostModel>> getAllPosts({int page = 1, int limit = 20});
  Future<PostModel> createPost(PostModel post);
  Future<List<PostModel>> getMyPosts();
  Future<PostModel?> getPostById(String postId);
  Future<PostModel> updatePost(String postId, PostModel post);
  Future<bool> deletePost(String postId);
}
