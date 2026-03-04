import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';
import 'package:petcare/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:petcare/features/reviews/presentation/view_model/review_view_model.dart';

class BookingHistoryWidget extends ConsumerWidget {
  final bool isLoading;
  final String? error;
  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> historyBookings;
  final Future<void> Function() onReload;

  const BookingHistoryWidget({
    super.key,
    required this.isLoading,
    required this.error,
    required this.upcomingBookings,
    required this.historyBookings,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          backgroundColor: AppColors.iconPrimaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onReload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _BookingList(
                    bookings: upcomingBookings,
                    emptyMessage: 'No upcoming appointments',
                    onRefresh: onReload,
                  ),
                  _BookingList(
                    bookings: historyBookings,
                    emptyMessage: 'No booking history yet',
                    onRefresh: onReload,
                  ),
                ],
              ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingEntity> bookings;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return _BookingCard(booking: bookings[index]);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;

  const _BookingCard({required this.booking});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDT = DateTime.tryParse(booking.startTime);
    final dateStr = startDT != null
        ? DateFormat('EEE, MMM d, yyyy').format(startDT)
        : booking.startTime;
    final timeStr = startDT != null
        ? DateFormat('hh:mm a').format(startDT)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: _statusColor(booking.status)),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status[0].toUpperCase() +
                        booking.status.substring(1),
                    style: TextStyle(
                      color: _statusColor(booking.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (timeStr.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(timeStr, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
            if (booking.price != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '\$${booking.price!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.successColor,
                    ),
                  ),
                ],
              ),
            ],
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                booking.notes!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
            // Rate Service button for completed bookings
            if (booking.status.toLowerCase() == 'completed' &&
                booking.providerId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showRateServiceSheet(context, booking),
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Rate Service'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFA000),
                    side: const BorderSide(color: Color(0xFFFFA000)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRateServiceSheet(BuildContext context, BookingEntity booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RateServiceSheet(booking: booking),
    );
  }
}

// ── Rate Service Bottom Sheet ────────────────────────────────────────
class _RateServiceSheet extends ConsumerStatefulWidget {
  final BookingEntity booking;

  const _RateServiceSheet({required this.booking});

  @override
  ConsumerState<_RateServiceSheet> createState() => _RateServiceSheetState();
}

class _RateServiceSheetState extends ConsumerState<_RateServiceSheet> {
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

            Text(
              'Rate Your Experience',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            if (widget.booking.serviceTitle != null)
              Text(
                widget.booking.serviceTitle!,
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

            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us about your experience with this service...',
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
                      ? _submitReview
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
    try {
      final dataSource = ref.read(reviewRemoteDataSourceProvider);
      await dataSource.createReview(
        rating: _rating,
        comment: _commentController.text.trim(),
        providerId: widget.booking.providerId,
        bookingId: widget.booking.bookingId,
        reviewType: 'provider',
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit review: ${e.toString().replaceAll('Exception: ', '')}',
            ),
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
