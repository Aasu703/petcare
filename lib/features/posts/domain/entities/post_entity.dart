import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String? id;
  final String title;
  final String content;
  final String providerId;
  final String? providerName;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostEntity({
    this.id,
    required this.title,
    required this.content,
    required this.providerId,
    this.providerName,
    this.isPublic = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    providerId,
    providerName,
    isPublic,
    createdAt,
    updatedAt,
  ];
}
