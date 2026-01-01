import 'package:hive_flutter/adapters.dart';
import 'package:petcare/core/constants/hive_table_constant.dart';
import 'package:petcare/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String FirstName;
  @HiveField(3)
  final String LastName;
  @HiveField(4)
  final String phoneNumber;
  @HiveField(5)
  final String username;
  @HiveField(6)
  final String? password;
  @HiveField(7)
  final String? avatar;

  AuthHiveModel({
    String? userId,
    required this.email,
    required this.FirstName,
    required this.LastName,
    required this.phoneNumber,
    required this.username,
    this.password,
    this.avatar,
  }) : userId = userId ?? Uuid().v4();

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      email: entity.email,
      FirstName: entity.FirstName,
      LastName: entity.LastName,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      password: entity.password,
      avatar: entity.avatar,
    );
  }

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      email: email,
      FirstName: FirstName,
      LastName: LastName,
      phoneNumber: phoneNumber,
      username: username,
      password: password,
      avatar: avatar,
    );
  }
}
