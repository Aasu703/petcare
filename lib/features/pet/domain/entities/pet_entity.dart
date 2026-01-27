class PetEntity {
  final String id;
  final String name;
  final String gender;
  final String? imagePath;

  PetEntity({
    required this.id,
    required this.name,
    required this.gender,
    this.imagePath,
  });
}
