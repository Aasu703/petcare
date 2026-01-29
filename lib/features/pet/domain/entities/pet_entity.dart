import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String? id; // Made nullable since new pets won't have ID yet
  final String name;
  final String species;
  final String breed;
  final String age;
  final String weight;
  final String? imagePath;

  const PetEntity({
    this.id, // Made optional
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    this.imagePath,
  });

  // CopyWith method for easy updates
  PetEntity copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? age,
    String? weight,
    String? imagePath,
  }) {
    return PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [id, name, species, breed, age, weight, imagePath];

  @override
  bool get stringify => true; // For better debugging
}
