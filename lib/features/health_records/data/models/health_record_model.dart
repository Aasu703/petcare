import 'package:petcare/features/health_records/domain/entities/health_record_entity.dart';

class HealthRecordModel {
  final String? id;
  final String? recordType;
  final String? title;
  final String? description;
  final String? date;
  final String? nextDueDate;
  final int? attachmentsCount;
  final String? petId;
  final String? createdAt;
  final String? updatedAt;

  HealthRecordModel({
    this.id,
    this.recordType,
    this.title,
    this.description,
    this.date,
    this.nextDueDate,
    this.attachmentsCount,
    this.petId,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      recordType: json['recordType']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      nextDueDate: json['nextDueDate']?.toString(),
      attachmentsCount: (json['attachmentsCount'] as num?)?.toInt(),
      petId: json['petId']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordType': recordType,
      'title': title,
      'description': description,
      'date': date,
      'nextDueDate': nextDueDate,
      'attachmentsCount': attachmentsCount,
      'petId': petId,
    };
  }

  HealthRecordEntity toEntity() {
    return HealthRecordEntity(
      recordId: id,
      recordType: recordType,
      title: title,
      description: description,
      date: date,
      nextDueDate: nextDueDate,
      attachmentsCount: attachmentsCount,
      petId: petId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory HealthRecordModel.fromEntity(HealthRecordEntity entity) {
    return HealthRecordModel(
      id: entity.recordId,
      recordType: entity.recordType,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      nextDueDate: entity.nextDueDate,
      attachmentsCount: entity.attachmentsCount,
      petId: entity.petId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<HealthRecordEntity> toEntityList(List<HealthRecordModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
