import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/reviews/domain/entities/review_entity.dart';
import 'package:petcare/features/reviews/presentation/view_model/review_view_model.dart';
import 'package:petcare/shared/widgets/index.dart';

class ProviderReviewsPage extends ConsumerWidget {
  final String providerId;

  const ProviderReviewsPage({super.key, required this.providerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewProvider(providerId));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            backgroundColor: context.primaryColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Reviews & Ratings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.rate_review_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => _showAddReviewSheet(context, ref),
                  tooltip: 'Write a review',
                ),
              ),
            ],
          ),
        ],
        body: state.isLoading
            ? const LoadingIndicator(message: 'Loading reviews...')
            : state.error != null
            ? ErrorState(
                title: 'Error loading reviews',
                message: state.error,
                actionLabel: 'Retry',
                onAction: () => ref
                    .read(reviewProvider(providerId).notifier)
                    .loadReviews(providerId),
              )
            : RefreshIndicator(
                color: context.primaryColor,
                onRefresh: () => ref
                    .read(reviewProvider(providerId).notifier)
                    .loadReviews(providerId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Rating summary card
                    if (state.ratingBreakdown != null)
                      _RatingSummaryCard(breakdown: state.ratingBreakdown!),

                    const SizedBox(height: 20),

                    // Reviews header
                    if (state.reviews.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.forum_rounded,
                                size: 16,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'All Reviews',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.reviews.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Review list or empty state
                    if (state.reviews.isEmpty)
                      _EmptyReviewsState(
                        onAddReview: () => _showAddReviewSheet(context, ref),
                      )
                    else
                      ...state.reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      // Floating add review button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewSheet(context, ref),
        backgroundColor: context.primaryColor,
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Write Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showAddReviewSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddReviewSheet(providerId: providerId, parentRef: ref),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────
class _EmptyReviewsState extends StatelessWidget {
  final VoidCallback onAddReview;
  const _EmptyReviewsState({required this.onAddReview});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: context.primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to share your experience!',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAddReview,
              icon: Icon(
                Icons.edit_rounded,
                size: 16,
                color: context.primaryColor,
              ),
              label: Text(
                'Write a Review',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rating summary card ─────────────────────────────────────────────────
class _RatingSummaryCard extends StatelessWidget {
  final RatingBreakdown breakdown;

  const _RatingSummaryCard({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Big score
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  breakdown.averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    final value = breakdown.averageRating - i;
                    return Icon(
                      value >= 1
                          ? Icons.star_rounded
                          : value > 0
                          ? Icons.star_half_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                      color: const Color(0xFFFFA000),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  '${breakdown.totalReviews} reviews',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 100,
            color: context.borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          // Right: Breakdown bars
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _RatingBar(
                  stars: 5,
                  count: breakdown.excellent,
                  total: breakdown.totalReviews,
                  color: context.primaryColor,
                ),
                _RatingBar(
                  stars: 4,
                  count: breakdown.good,
                  total: breakdown.totalReviews,
                  color: AppColors.primaryLightColor,
                ),
                _RatingBar(
                  stars: 3,
                  count: breakdown.average,
                  total: breakdown.totalReviews,
                  color: AppColors.warningColor,
                ),
                _RatingBar(
                  stars: 2,
                  count: breakdown.belowAverage,
                  total: breakdown.totalReviews,
                  color: AppColors.accentColor,
                ),
                _RatingBar(
                  stars: 1,
                  count: breakdown.poor,
                  total: breakdown.totalReviews,
                  color: AppColors.errorColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;
  final Color color;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$stars',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
              ),
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFA000)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: context.borderColor,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 7,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review card ─────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: context.primaryColor.withOpacity(0.1),
                child:
                    review.userProfileImage != null &&
                        review.userProfileImage!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          review.userProfileImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            (review.userName ?? 'A')[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        (review.userName ?? 'A')[0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.primaryColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Compact rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA000).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFFA000),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ── Add review bottom sheet ─────────────────────────────────────────────
class _AddReviewSheet extends StatefulWidget {
  final String providerId;
  final WidgetRef parentRef;

  const _AddReviewSheet({required this.providerId, required this.parentRef});

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  double _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  static const _ratingLabels = [
    '',
    'Poor',
    'Below Average',
    'Average',
    'Good',
    'Excellent',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Share Your Experience',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Help other pet owners make informed decisions',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = (i + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedScale(
                      scale: i < _rating ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        i < _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 44,
                        color: i < _rating
                            ? const Color(0xFFFFA000)
                            : context.borderColor,
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Rating label
            if (_rating > 0) ...[
              const SizedBox(height: 6),
              Text(
                _ratingLabels[_rating.toInt()],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Tell others about your experience with this provider...',
                hintStyle: TextStyle(color: context.hintColor, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: context.primaryColor,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: context.backgroundColor,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: _rating > 0
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _rating > 0 && !_isSubmitting
                      ? () => _submitReview()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: context.primaryColor.withOpacity(
                      0.3,
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    final success = await widget.parentRef
        .read(reviewProvider(widget.providerId).notifier)
        .submitReview(
          rating: _rating,
          comment: _commentController.text.trim(),
          providerId: widget.providerId,
        );
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review submitted successfully!'),
            backgroundColor: context.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit review. Please try again.'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
