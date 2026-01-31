import 'package:json_annotation/json_annotation.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

part 'pet_api_model.g.dart';

@JsonSerializable()
class PetApiModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'species')
  final String species;

  @JsonKey(name: 'breed')
  final String? breed;

  @JsonKey(name: 'age')
  final int? age; // Changed from String to int

  @JsonKey(name: 'weight')
  final double? weight; // Changed from String to double

  @JsonKey(name: 'ownerId')
  final String? ownerId; // Added for response

  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @JsonKey(name: 'createdAt')
  final String? createdAt;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  PetApiModel({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    this.ownerId,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // JSON serialization
  factory PetApiModel.fromJson(Map<String, dynamic> json) =>
      _$PetApiModelFromJson(json);

  // For CREATE request - exclude fields backend generates
  Map<String, dynamic> toJsonForCreate() {
    return {
      'name': name,
      'species': species,
      if (breed != null && breed!.isNotEmpty) 'breed': breed,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      // DON'T send ownerId - backend adds it from JWT
      // DON'T send _id - backend generates it
    };
  }

  // For general serialization (includes all fields)
  Map<String, dynamic> toJson() => _$PetApiModelToJson(this);

  // Convert to domain entity
  PetEntity toEntity() {
    return PetEntity(
      petId: id ?? '',
      name: name,
      species: species,
      breed: breed,
      age: age,
      weight: weight,
      ownerId: ownerId,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create from domain entity
  factory PetApiModel.fromEntity(PetEntity entity) {
    return PetApiModel(
      id: entity.petId?.isEmpty ?? true ? null : entity.petId,
      name: entity.name,
      species: entity.species,
      breed: entity.breed,
      age: entity.age,
      weight: entity.weight,
      ownerId: entity.ownerId,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Convert list to entities
  static List<PetEntity> toEntityList(List<PetApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
