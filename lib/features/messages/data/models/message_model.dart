import 'package:petcare/features/messages/domain/entities/message_entity.dart';

class MessageModel {
  final String? id;
  final String content;
  final String? userId;
  final String? userName;
  final String? userImage;
  final String? createdAt;
  final String? updatedAt;

  MessageModel({
    this.id,
    required this.content,
    this.userId,
    this.userName,
    this.userImage,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic userField = json['userId'];
    String? parsedUserId;
    String? parsedUserName;
    String? parsedUserImage;

    if (userField is Map<String, dynamic>) {
      parsedUserId =
          userField['_id']?.toString() ?? userField['id']?.toString();
      final firstName = userField['Firstname']?.toString();
      final lastName = userField['Lastname']?.toString();
      final fullName = [firstName, lastName]
          .where((part) => part != null && part.trim().isNotEmpty)
          .join(' ')
          .trim();
      parsedUserName = fullName.isNotEmpty
          ? fullName
          : userField['username']?.toString() ?? userField['email']?.toString();
      parsedUserImage = userField['imageUrl']?.toString();
    } else {
      parsedUserId = userField?.toString();
    }

    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      content: json['content']?.toString() ?? '',
      userId: parsedUserId,
      userName: parsedUserName,
      userImage: parsedUserImage,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (userId != null && userId!.isNotEmpty) 'userId': userId,
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      content: content,
      userId: userId ?? '',
      userName: userName,
      userImage: userImage,
      createdAt: _parseDate(createdAt),
      updatedAt: _parseDate(updatedAt),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static List<MessageEntity> toEntityList(List<MessageModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
