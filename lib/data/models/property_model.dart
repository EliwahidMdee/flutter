import 'package:json_annotation/json_annotation.dart';

part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  final int id;
  final String name;
  final String address;
  final String? description;
  @JsonKey(name: 'property_type')
  final String propertyType;
  @JsonKey(name: 'total_units')
  final int totalUnits;
  @JsonKey(name: 'occupied_units')
  final int? occupiedUnits;
  @JsonKey(name: 'landlord_id')
  final int landlordId;
  final String? image;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relationships
  final LandlordInfo? landlord;
  final List<UnitModel>? units;
  
  PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.propertyType,
    required this.totalUnits,
    this.occupiedUnits,
    required this.landlordId,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.landlord,
    this.units,
  });
  
  factory PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
  
  // Computed properties
  int get availableUnits => totalUnits - (occupiedUnits ?? 0);
  
  double get occupancyRate {
    if (totalUnits == 0) return 0.0;
    return (occupiedUnits ?? 0) / totalUnits;
  }
  
  String get occupancyPercentage {
    return '${(occupancyRate * 100).toStringAsFixed(1)}%';
  }
}

@JsonSerializable()
class LandlordInfo {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  
  LandlordInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });
  
  factory LandlordInfo.fromJson(Map<String, dynamic> json) =>
      _$LandlordInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$LandlordInfoToJson(this);
}

@JsonSerializable()
class UnitModel {
  final int id;
  @JsonKey(name: 'unit_number')
  final String unitNumber;
  @JsonKey(name: 'property_id')
  final int propertyId;
  final int bedrooms;
  final int bathrooms;
  @JsonKey(name: 'square_feet')
  final double? squareFeet;
  @JsonKey(name: 'monthly_rent')
  final double monthlyRent;
  @JsonKey(name: 'is_occupied')
  final bool isOccupied;
  final String? description;
  
  UnitModel({
    required this.id,
    required this.unitNumber,
    required this.propertyId,
    required this.bedrooms,
    required this.bathrooms,
    this.squareFeet,
    required this.monthlyRent,
    required this.isOccupied,
    this.description,
  });
  
  factory UnitModel.fromJson(Map<String, dynamic> json) =>
      _$UnitModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UnitModelToJson(this);
}
