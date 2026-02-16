import 'package:equatable/equatable.dart';

class ProviderEntity extends Equatable {
  final String? providerId;
  final String? userId; // FK → User
  final String businessName;
  final String address;
  final String phone;
  final int rating;
  final String? providerType; // shop, vet, babysitter
  final String? email;
  final String? password;

  ProviderEntity({
    this.providerId,
    this.userId,
    required this.businessName,
    required this.address,
    required this.phone,
    required this.rating,
    this.providerType,
    this.email,
    this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    providerId,
    userId,
    businessName,
    address,
    phone,
    rating,
    providerType,
    email,
    password,
  ];
}
