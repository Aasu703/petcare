import 'package:equatable/equatable.dart';

class HealthRecordEntity extends Equatable {
  final String? recordId;
  final String? recordType;
  final String? title;
  final String? description;
  final String? date;
  final String? nextDueDate;
  final int? attachmentsCount;
  final String? petId;
  final String? createdAt;
  final String? updatedAt;

  const HealthRecordEntity({
    this.recordId,
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

  @override
  List<Object?> get props => [
    recordId,
    recordType,
    title,
    description,
    date,
    nextDueDate,
    attachmentsCount,
    petId,
    createdAt,
    updatedAt,
  ];
}
