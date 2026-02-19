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
  final String? prescribedByProviderId;
  final String? prescribedByProviderName;
  final String? prescribedForUserId;
  final String? prescribedForUserName;
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
    this.prescribedByProviderId,
    this.prescribedByProviderName,
    this.prescribedForUserId,
    this.prescribedForUserName,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value is String) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        return (value['_id'] ?? value['id'])?.toString();
      }
      return null;
    }

    final prescribedBy = json['prescribedByProvider'] as Map<String, dynamic>?;
    final owner = json['owner'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;

    return HealthRecordModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      recordType: json['recordType']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      nextDueDate: json['nextDueDate']?.toString(),
      attachmentsCount: (json['attachmentsCount'] as num?)?.toInt(),
      petId: extractId(json['petId']),
      prescribedByProviderId:
          extractId(json['prescribedByProviderId']) ??
          extractId(json['prescribedBy']) ??
          extractId(json['providerId']) ??
          extractId(prescribedBy),
      prescribedByProviderName:
          json['prescribedByProviderName']?.toString() ??
          json['prescribedByName']?.toString() ??
          prescribedBy?['businessName']?.toString(),
      prescribedForUserId:
          extractId(json['prescribedForUserId']) ??
          extractId(json['ownerId']) ??
          extractId(json['userId']) ??
          extractId(owner) ??
          extractId(user),
      prescribedForUserName:
          json['prescribedForUserName']?.toString() ??
          json['ownerName']?.toString() ??
          owner?['name']?.toString() ??
          user?['name']?.toString(),
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
      prescribedByProviderId: prescribedByProviderId,
      prescribedByProviderName: prescribedByProviderName,
      prescribedForUserId: prescribedForUserId,
      prescribedForUserName: prescribedForUserName,
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
      prescribedByProviderId: entity.prescribedByProviderId,
      prescribedByProviderName: entity.prescribedByProviderName,
      prescribedForUserId: entity.prescribedForUserId,
      prescribedForUserName: entity.prescribedForUserName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<HealthRecordEntity> toEntityList(List<HealthRecordModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
