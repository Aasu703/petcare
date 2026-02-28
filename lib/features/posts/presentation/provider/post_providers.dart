import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';
import 'package:petcare/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:petcare/features/posts/domain/usecases/get_all_posts_usecase.dart';
import 'package:petcare/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:petcare/features/posts/data/repositories/post_repository.dart';

// State
class PostState {
  final bool isLoading;
  final List<PostEntity> posts;
  final String? error;

  const PostState({this.isLoading = false, this.posts = const [], this.error});

  PostState copyWith({
    bool? isLoading,
    List<PostEntity>? posts,
    String? error,
    bool clearError = false,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Usecase Providers
final getAllPostsUsecaseProvider = Provider<GetAllPostsUsecase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return GetAllPostsUsecase(repository: repository);
});

final getMyPostsUsecaseProvider = Provider<GetMyPostsUsecase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return GetMyPostsUsecase(repository: repository);
});

final createPostUsecaseProvider = Provider<CreatePostUsecase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return CreatePostUsecase(repository: repository);
});

// Notifier
class PostNotifier extends StateNotifier<PostState> {
  final GetAllPostsUsecase _getAllPostsUsecase;
  final GetMyPostsUsecase _getMyPostsUsecase;
  final CreatePostUsecase _createPostUsecase;
  final UserSessionService _sessionService;

  PostNotifier(
    this._getAllPostsUsecase,
    this._getMyPostsUsecase,
    this._createPostUsecase,
    this._sessionService,
  ) : super(const PostState());

  Future<void> getAllPosts({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllPostsUsecase(
      GetAllPostsParams(page: page, limit: limit),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (posts) => state = state.copyWith(isLoading: false, posts: posts),
    );
  }

  Future<void> getMyPosts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getMyPostsUsecase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (posts) => state = state.copyWith(isLoading: false, posts: posts),
    );
  }

  Future<void> createPost(String title, String content) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final userId = _sessionService.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final post = PostEntity(
        title: title,
        content: content,
        providerId: userId,
        isPublic: true,
      );

      final result = await _createPostUsecase(post);

      result.fold(
        (failure) =>
            state = state.copyWith(isLoading: false, error: failure.message),
        (newPost) {
          final updatedPosts = [...state.posts, newPost];
          state = state.copyWith(isLoading: false, posts: updatedPosts);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final postNotifierProvider = StateNotifierProvider<PostNotifier, PostState>((
  ref,
) {
  final getAllPostsUsecase = ref.read(getAllPostsUsecaseProvider);
  final getMyPostsUsecase = ref.read(getMyPostsUsecaseProvider);
  final createPostUsecase = ref.read(createPostUsecaseProvider);
  final sessionService = ref.read(userSessionServiceProvider);
  return PostNotifier(
    getAllPostsUsecase,
    getMyPostsUsecase,
    createPostUsecase,
    sessionService,
  );
});
