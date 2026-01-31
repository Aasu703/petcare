import 'package:petcare/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String? Firstname;
  final String? Lastname;
  final String email;
  final String? phoneNumber;
  final String? username;
  final String? password;
  final String? confirmPassword;
  final String? avatar;

  AuthApiModel({
    this.id,
    this.Firstname,
    this.Lastname,
    required this.email,
    this.phoneNumber,
    this.username,
    this.password,
    this.confirmPassword,
    this.avatar,
  });

  // toJSON
  Map<String, dynamic> toJSON() {
    return {
      "Firstname": Firstname,
      "Lastname": Lastname,
      "email": email,
      "phone": phoneNumber,
      "username": username,
      "password": password,
      "confirmPassword": confirmPassword,
      "imageUrl": avatar,
    };
  }

  // FromJSON
  factory AuthApiModel.fromJSON(Map<String, dynamic> json) {
    final emailValue = json["email"]?.toString() ?? '';
    return AuthApiModel(
      id: (json["_id"] ?? json["id"])?.toString(),
      Firstname: (json["Firstname"] ?? json["name"])?.toString(),
      Lastname: json["Lastname"]?.toString(),
      email: emailValue,
      phoneNumber: (json["phoneNumber"] ?? json["phone"])?.toString(),
      username: (json["username"] ?? emailValue).toString(),
      avatar: (json["imageUrl"] ?? json["avatar"] ?? json["profilePicture"])
          ?.toString(),
    );
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id ?? '',
      email: email,
      FirstName: Firstname ?? '',
      LastName: Lastname ?? '',
      phoneNumber: phoneNumber ?? '',
      username: username ?? email.split('@').first,
      password: password,
      avatar: avatar,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      Firstname: entity.FirstName,
      Lastname: entity.LastName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      avatar: entity.avatar,
    );
  }
  // toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
