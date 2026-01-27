import '../../domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  PetModel({
    required super.id,
    required super.name,
    required super.gender,
    super.imagePath,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'gender': gender, 'imagePath': imagePath};
  }
}
