import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

class BookingState {
  final bool isLoading;
  final String? error;
  final List<BookingEntity> bookings;
  final BookingEntity? createdBooking;
  final String selectedFilter;

  const BookingState({
    this.isLoading = false,
    this.error,
    this.bookings = const [],
    this.createdBooking,
    this.selectedFilter = 'all',
  });

  BookingState copyWith({
    bool? isLoading,
    String? error,
    List<BookingEntity>? bookings,
    BookingEntity? createdBooking,
    String? selectedFilter,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookings: bookings ?? this.bookings,
      createdBooking: createdBooking ?? this.createdBooking,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<BookingEntity> get filteredBookings {
    if (selectedFilter == 'all') return bookings;
    return bookings.where((b) => b.status == selectedFilter).toList();
  }
}
