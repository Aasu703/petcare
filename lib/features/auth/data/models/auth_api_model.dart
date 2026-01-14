import 'package:petcare/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;
  final String username;
  final String? password;
  final String? avatar;

  AuthApiModel({
    this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.avatar,
  });

  // toJSON
  Map<String, dynamic> toJSON() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phoneNumber": phoneNumber,
      "username": username,
      "password": password,
      "avatar": avatar,
    };
  }

  // FromJSON
  factory AuthApiModel.fromJSON(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json["_id"] ?? json["id"]) as String?,
      firstName: (json["firstName"] ?? json["name"]) as String?,
      lastName: json["lastName"] as String?,
      email: json["email"] as String,
      phoneNumber: json["phoneNumber"] as String?,
      username: json["username"] as String,
      avatar: (json["avatar"] ?? json["profilePicture"]) as String?,
    );
  }

  // toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id ?? '',
      email: email,
      FirstName: firstName ?? '',
      LastName: lastName ?? '',
      phoneNumber: phoneNumber ?? '',
      username: username,
      password: password,
      avatar: avatar,
    );
  }

  // fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      firstName: entity.FirstName,
      lastName: entity.LastName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      avatar: entity.avatar,
    );
  }
  // toEntityList
  static List<AuthEntity> toEnityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
