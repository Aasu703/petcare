import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:petcare/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:petcare/features/reviews/domain/entities/review_entity.dart';

class ReviewState {
  final bool isLoading;
  final String? error;
  final List<ReviewEntity> reviews;
  final RatingBreakdown? ratingBreakdown;
  final bool isSubmitting;

  const ReviewState({
    this.isLoading = false,
    this.error,
    this.reviews = const [],
    this.ratingBreakdown,
    this.isSubmitting = false,
  });

  ReviewState copyWith({
    bool? isLoading,
    String? error,
    List<ReviewEntity>? reviews,
    RatingBreakdown? ratingBreakdown,
    bool? isSubmitting,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      reviews: reviews ?? this.reviews,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRemoteDataSource _dataSource;

  ReviewNotifier(this._dataSource) : super(const ReviewState());

  Future<void> loadReviews(String providerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _dataSource.getReviewsByProvider(providerId),
        _dataSource.getRatingBreakdown(providerId),
      ]);
      state = state.copyWith(
        isLoading: false,
        reviews: results[0] as List<ReviewEntity>,
        ratingBreakdown: results[1] as RatingBreakdown,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitReview({
    required double rating,
    String? comment,
    required String providerId,
    String? bookingId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _dataSource.createReview(
        rating: rating,
        comment: comment,
        providerId: providerId,
        bookingId: bookingId,
        reviewType: 'provider',
      );
      // Reload reviews after submission
      await loadReviews(providerId);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final reviewProvider = StateNotifierProvider.autoDispose
    .family<ReviewNotifier, ReviewState, String>((ref, providerId) {
      final dataSource = ref.read(reviewRemoteDataSourceProvider);
      final notifier = ReviewNotifier(dataSource);
      notifier.loadReviews(providerId);
      return notifier;
    });
