import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

class PetApiModel {
  final String? id; // Made nullable
  final String name;
  final String species;
  final String breed;
  final String age;
  final String weight;
  final String imagePath;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PetApiModel({
    this.id, // Made optional
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.weight,
    required this.imagePath,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'weight': weight,
      // Don't include id or ownerId - backend handles these
    };
  }

  factory PetApiModel.fromJson(Map<String, dynamic> json) {
    return PetApiModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      age: json['age']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      imagePath: json['imageUrl'] ?? '',
      ownerId: json['ownerId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  PetEntity toEntity() {
    return PetEntity(
      id: id,
      name: name,
      species: species,
      breed: breed,
      age: age,
      weight: weight,
      imagePath: imagePath,
    );
  }

  factory PetApiModel.fromEntity(PetEntity entity) {
    return PetApiModel(
      id: entity.id,
      name: entity.name,
      species: entity.species,
      breed: entity.breed,
      age: entity.age,
      weight: entity.weight,
      imagePath: entity.imagePath ?? '',
    );
  }

  static List<PetEntity> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PetApiModel.fromJson(json).toEntity())
        .toList();
  }
}
