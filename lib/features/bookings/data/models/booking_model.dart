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
  final String? userName;
  final String? userEmail;
  final String? petName;
  final String? providerBusinessName;
  final String? serviceTitle;
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
    this.userName,
    this.userEmail,
    this.petName,
    this.providerBusinessName,
    this.serviceTitle,
    this.createdAt,
    this.updatedAt,
  });

  // FROM JSON - supports both plain ids and enriched nested objects.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value is String) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        return (value['_id'] ?? value['id'])?.toString();
      }
      return null;
    }

    final user = json['user'] as Map<String, dynamic>?;
    final pet = json['pet'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;

    return BookingModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      notes: json['notes']?.toString(),
      serviceId: extractId(json['serviceId']) ?? extractId(service),
      userId: extractId(json['userId']) ?? extractId(user),
      petId: extractId(json['petId']) ?? extractId(pet),
      providerId: extractId(json['providerId']) ?? extractId(provider),
      providerServiceId: json['providerServiceId']?.toString(),
      userName: json['userName']?.toString() ?? user?['name']?.toString(),
      userEmail: json['userEmail']?.toString() ?? user?['email']?.toString(),
      petName: json['petName']?.toString() ?? pet?['name']?.toString(),
      providerBusinessName:
          json['providerName']?.toString() ??
          provider?['businessName']?.toString(),
      serviceTitle:
          json['serviceTitle']?.toString() ?? service?['title']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  // TO JSON - fields expected by booking create/update APIs.
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
      userName: userName,
      userEmail: userEmail,
      petName: petName,
      providerBusinessName: providerBusinessName,
      serviceTitle: serviceTitle,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

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
      userName: entity.userName,
      userEmail: entity.userEmail,
      petName: entity.petName,
      providerBusinessName: entity.providerBusinessName,
      serviceTitle: entity.serviceTitle,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<BookingEntity> toEntityList(List<BookingModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
