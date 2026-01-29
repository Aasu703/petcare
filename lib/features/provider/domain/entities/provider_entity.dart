import 'package:equatable/equatable.dart';

class ProviderEntity extends Equatable {
  final String providerId;
  final String userId; // FK → User
  final String businessName;
  final String address;
  final String phone;
  final int rating;

  const ProviderEntity({
    required this.providerId,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.rating,
  });

  @override
  List<Object?> get props => [
    providerId,
    userId,
    businessName,
    address,
    phone,
    rating,
  ];
}
