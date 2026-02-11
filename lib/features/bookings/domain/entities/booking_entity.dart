import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String? bookingId;
  final String startTime;
  final String endTime;
  final String status; // pending, confirmed, completed, cancelled
  final double? price;
  final String? notes;
  final String? serviceId;
  final String? userId;
  final String? petId;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;

  const BookingEntity({
    this.bookingId,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
    this.price,
    this.notes,
    this.serviceId,
    this.userId,
    this.petId,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    bookingId,
    startTime,
    endTime,
    status,
    price,
    notes,
    serviceId,
    userId,
    petId,
    providerId,
    createdAt,
    updatedAt,
  ];

  BookingEntity copyWith({
    String? bookingId,
    String? startTime,
    String? endTime,
    String? status,
    double? price,
    String? notes,
    String? serviceId,
    String? userId,
    String? petId,
    String? providerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return BookingEntity(
      bookingId: bookingId ?? this.bookingId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
