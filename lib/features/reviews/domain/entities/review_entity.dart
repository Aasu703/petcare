import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? reviewId;
  final double rating;
  final String? comment;
  final String? userId;
  final String? userName;
  final String? userProfileImage;
  final String? providerId;
  final String? providerServiceId;
  final String? productId;
  final String? bookingId;
  final String? reviewType;
  final DateTime? createdAt;

  const ReviewEntity({
    this.reviewId,
    required this.rating,
    this.comment,
    this.userId,
    this.userName,
    this.userProfileImage,
    this.providerId,
    this.providerServiceId,
    this.productId,
    this.bookingId,
    this.reviewType,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    reviewId,
    rating,
    comment,
    userId,
    userName,
    userProfileImage,
    providerId,
    providerServiceId,
    productId,
    bookingId,
    reviewType,
    createdAt,
  ];
}

class RatingBreakdown extends Equatable {
  final double averageRating;
  final int totalReviews;
  final int excellent;
  final int good;
  final int average;
  final int belowAverage;
  final int poor;

  const RatingBreakdown({
    required this.averageRating,
    required this.totalReviews,
    required this.excellent,
    required this.good,
    required this.average,
    required this.belowAverage,
    required this.poor,
  });

  factory RatingBreakdown.empty() => const RatingBreakdown(
    averageRating: 0,
    totalReviews: 0,
    excellent: 0,
    good: 0,
    average: 0,
    belowAverage: 0,
    poor: 0,
  );

  @override
  List<Object?> get props => [averageRating, totalReviews, excellent, good, average, belowAverage, poor];
}
