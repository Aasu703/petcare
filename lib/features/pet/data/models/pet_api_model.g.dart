// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetApiModel _$PetApiModelFromJson(Map<String, dynamic> json) => PetApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: (json['age'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PetApiModelToJson(PetApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'weight': instance.weight,
      'ownerId': instance.ownerId,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
