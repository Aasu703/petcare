import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

class BookingModel {
  final String? id;
  final String startTime;
  final String endTime;
  final String status;
  final double? price;
  final String? notes;
  final String? serviceId;
  final String? userId;
  final String? petId;
  final String? providerId;
  final String? providerServiceId;
  final String? createdAt;
  final String? updatedAt;

  BookingModel({
    this.id,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
    this.price,
    this.notes,
    this.serviceId,
    this.userId,
    this.petId,
    this.providerId,
    this.providerServiceId,
    this.createdAt,
    this.updatedAt,
  });

  // FROM JSON — matches backend field names exactly
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      notes: json['notes']?.toString(),
      serviceId: json['serviceId']?.toString(),
      userId: json['userId']?.toString(),
      petId: json['petId']?.toString(),
      providerId: json['providerId']?.toString(),
      providerServiceId: json['providerServiceId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  // TO JSON — matches backend expected fields exactly
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'startTime': startTime, 'endTime': endTime};
    if (price != null) json['price'] = price;
    if (notes != null) json['notes'] = notes;
    if (serviceId != null) json['serviceId'] = serviceId;
    if (userId != null) json['userId'] = userId;
    if (petId != null) json['petId'] = petId;
    if (providerId != null) json['providerId'] = providerId;
    if (providerServiceId != null) {
      json['providerServiceId'] = providerServiceId;
    }
    return json;
  }

  // TO ENTITY
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: id,
      startTime: startTime,
      endTime: endTime,
      status: status,
      price: price,
      notes: notes,
      serviceId: serviceId,
      userId: userId,
      petId: petId,
      providerId: providerId,
      providerServiceId: providerServiceId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // FROM ENTITY
  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.bookingId,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      price: entity.price,
      notes: entity.notes,
      serviceId: entity.serviceId,
      userId: entity.userId,
      petId: entity.petId,
      providerId: entity.providerId,
      providerServiceId: entity.providerServiceId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // TO ENTITY LIST
  static List<BookingEntity> toEntityList(List<BookingModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
