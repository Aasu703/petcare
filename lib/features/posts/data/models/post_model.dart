class PostModel {
  final String? id;
  final String title;
  final String content;
  final String providerId;
  final String? providerName;
  final bool isPublic;
  final String? createdAt;

  PostModel({
    this.id,
    required this.title,
    required this.content,
    required this.providerId,
    this.providerName,
    this.isPublic = true,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName']?.toString(),
      isPublic: json['isPublic'] ?? true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'providerId': providerId,
      'providerName': providerName,
      'isPublic': isPublic,
    };
  }
}
