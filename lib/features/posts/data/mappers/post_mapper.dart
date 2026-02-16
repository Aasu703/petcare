import 'package:petcare/features/posts/data/models/post_model.dart';
import 'package:petcare/features/posts/domain/entities/post_entity.dart';

class PostMapper {
  static PostEntity toEntity(PostModel model) {
    return PostEntity(
      id: model.id,
      title: model.title,
      content: model.content,
      providerId: model.providerId,
      providerName: model.providerName,
      isPublic: model.isPublic,
      createdAt: model.createdAt != null
          ? DateTime.tryParse(model.createdAt!)
          : null,
      updatedAt: null, // Model doesn't have updatedAt
    );
  }

  static PostModel toModel(PostEntity entity) {
    return PostModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      providerId: entity.providerId,
      providerName: entity.providerName,
      isPublic: entity.isPublic,
      createdAt: entity.createdAt?.toIso8601String(),
    );
  }

  static List<PostEntity> toEntityList(List<PostModel> models) {
    return models.map(toEntity).toList();
  }

  static List<PostModel> toModelList(List<PostEntity> entities) {
    return entities.map(toModel).toList();
  }
}
