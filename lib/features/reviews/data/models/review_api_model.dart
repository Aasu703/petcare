import '../../domain/entities/review_entity.dart';

class ReviewApiModel {
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

  ReviewApiModel({
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

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    return ReviewApiModel(
      reviewId: (json['_id'] ?? json['id'])?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      comment: json['comment']?.toString(),
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      userProfileImage: json['userProfileImage']?.toString(),
      providerId: json['providerId']?.toString(),
      providerServiceId: json['providerServiceId']?.toString(),
      productId: json['productId']?.toString(),
      bookingId: json['bookingId']?.toString(),
      reviewType: json['reviewType']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (rating > 0) 'rating': rating,
      if (comment != null) 'comment': comment,
      if (providerId != null) 'providerId': providerId,
      if (providerServiceId != null) 'providerServiceId': providerServiceId,
      if (productId != null) 'productId': productId,
      if (bookingId != null) 'bookingId': bookingId,
      if (reviewType != null) 'reviewType': reviewType,
    };
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      providerId: providerId,
      providerServiceId: providerServiceId,
      productId: productId,
      bookingId: bookingId,
      reviewType: reviewType,
      createdAt: createdAt,
    );
  }

  static List<ReviewEntity> toEntityList(List<ReviewApiModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }
}
