import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String? petId;
  final String name;
  final String species;
  final String? breed;
  final int? age; // Changed from String to int
  final double? weight; // Changed from String to double
  final String? ownerId;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? assignedVetId;
  final String? assignedVetName;
  final String? assignedAt;

  const PetEntity({
    this.petId,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.ownerId,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.assignedVetId,
    this.assignedVetName,
    this.assignedAt,
  });

  @override
  List<Object?> get props => [
    petId,
    name,
    species,
    breed,
    age,
    weight,
    ownerId,
    imageUrl,
    createdAt,
    updatedAt,
    assignedVetId,
    assignedVetName,
    assignedAt,
  ];

  PetEntity copyWith({
    String? petId,
    String? name,
    String? species,
    String? breed,
    int? age,
    double? weight,
    String? ownerId,
    String? imageUrl,
    String? createdAt,
    String? updatedAt,
    String? assignedVetId,
    String? assignedVetName,
    String? assignedAt,
  }) {
    return PetEntity(
      petId: petId ?? this.petId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedVetId: assignedVetId ?? this.assignedVetId,
      assignedVetName: assignedVetName ?? this.assignedVetName,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }
}
