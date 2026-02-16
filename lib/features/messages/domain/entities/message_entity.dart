import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String? id;
  final String content;
  final String userId;
  final String? userName;
  final String? userImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    this.id,
    required this.content,
    required this.userId,
    this.userName,
    this.userImage,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    userId,
    userName,
    userImage,
    createdAt,
    updatedAt,
  ];
}
