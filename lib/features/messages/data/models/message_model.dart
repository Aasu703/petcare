class MessageModel {
  final String? id;
  final String content;
  final String? userId;
  final String? createdAt;

  MessageModel({this.id, required this.content, this.userId, this.createdAt});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      content: json['content']?.toString() ?? '',
      userId: json['userId']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'content': content, 'userId': userId};
  }
}
