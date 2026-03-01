import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_client.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/reviews/data/models/review_api_model.dart';
import 'package:petcare/features/reviews/domain/entities/review_entity.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSource({required this.apiClient});

  Future<List<ReviewEntity>> getReviewsByProvider(String providerId, {int page = 1, int limit = 20}) async {
    final response = await apiClient.get(
      '${ApiEndpoints.reviewByProvider}/$providerId',
      queryParameters: {'page': page, 'limit': limit, 'enriched': 'true'},
    );
    final data = response.data;
    final rawList = _extractList(data);
    return rawList.map((json) => ReviewApiModel.fromJson(json).toEntity()).toList();
  }

  Future<RatingBreakdown> getRatingBreakdown(String providerId) async {
    final response = await apiClient.get(
      ApiEndpoints.reviewProviderRatingBreakdown(providerId),
    );
    final data = response.data;
    final breakdown = data is Map ? (data['data'] ?? data) : {};
    final bd = breakdown['breakdown'] ?? {};
    return RatingBreakdown(
      averageRating: (breakdown['averageRating'] is num) ? (breakdown['averageRating'] as num).toDouble() : 0,
      totalReviews: (breakdown['totalReviews'] is num) ? (breakdown['totalReviews'] as num).toInt() : 0,
      excellent: (bd['excellent'] is num) ? (bd['excellent'] as num).toInt() : 0,
      good: (bd['good'] is num) ? (bd['good'] as num).toInt() : 0,
      average: (bd['average'] is num) ? (bd['average'] as num).toInt() : 0,
      belowAverage: (bd['belowAverage'] is num) ? (bd['belowAverage'] as num).toInt() : 0,
      poor: (bd['poor'] is num) ? (bd['poor'] as num).toInt() : 0,
    );
  }

  Future<ReviewEntity> createReview({
    required double rating,
    String? comment,
    String? providerId,
    String? bookingId,
    String? reviewType,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.reviewCreate,
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (providerId != null) 'providerId': providerId,
        if (bookingId != null) 'bookingId': bookingId,
        'reviewType': reviewType ?? 'provider',
      },
    );
    final data = response.data;
    final reviewData = data is Map ? (data['data'] ?? data) : data;
    return ReviewApiModel.fromJson(reviewData).toEntity();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map) {
      final d = data['data'];
      if (d is List) return d.cast<Map<String, dynamic>>();
      if (d is Map) {
        final reviews = d['reviews'];
        if (reviews is List) return reviews.cast<Map<String, dynamic>>();
      }
    }
    return [];
  }
}
