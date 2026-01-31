import 'package:hive/hive.dart';
import 'package:petcare/core/constants/hive_table_constant.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:uuid/uuid.dart';

// Two things in hive
// 1 Box
// 2 Adapter : converts binary to objects
part 'provider_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.providerTypeId)
class ProviderHiveModel extends HiveObject {
  @HiveField(0)
  final String? providerId;
  @HiveField(1)
  final String business_Name;
  @HiveField(2)
  final String? address;
  @HiveField(3)
  final String? phone;
  @HiveField(4)
  final String? rating;

  // Constructor
  ProviderHiveModel({
    String? providerId,
    required this.business_Name,
    this.address,
    this.phone,
    this.rating,
  }) : providerId = providerId ?? Uuid().v4();

  // ToEntity this meaning to get request form
  ProviderEntity toEntity() {
    return ProviderEntity(
      providerId: providerId ?? '',
      userId: '',
      businessName: business_Name,
      address: address ?? '',
      phone: phone ?? '',
      rating: int.tryParse(rating ?? '0') ?? 0,
    );
  }

  // FromEntity

  factory ProviderHiveModel.fromEntity(ProviderEntity entity) {
    return ProviderHiveModel(
      providerId: entity.providerId.isNotEmpty ? entity.providerId : null,
      business_Name: entity.businessName,
      address: entity.address,
      phone: entity.phone,
      rating: entity.rating.toString(),
    );
  }

  // ToEntityList

  static List<ProviderEntity> toEntityList(List<ProviderHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
