// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) =>
    PropertyModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String?,
      propertyType: json['property_type'] as String,
      totalUnits: (json['total_units'] as num).toInt(),
      occupiedUnits: (json['occupied_units'] as num?)?.toInt(),
      landlordId: (json['landlord_id'] as num).toInt(),
      image: json['image'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      landlord: json['landlord'] == null
          ? null
          : LandlordInfo.fromJson(json['landlord'] as Map<String, dynamic>),
      units: (json['units'] as List<dynamic>?)
          ?.map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'description': instance.description,
      'property_type': instance.propertyType,
      'total_units': instance.totalUnits,
      'occupied_units': instance.occupiedUnits,
      'landlord_id': instance.landlordId,
      'image': instance.image,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'landlord': instance.landlord,
      'units': instance.units,
    };

LandlordInfo _$LandlordInfoFromJson(Map<String, dynamic> json) => LandlordInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$LandlordInfoToJson(LandlordInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

UnitModel _$UnitModelFromJson(Map<String, dynamic> json) => UnitModel(
      id: (json['id'] as num).toInt(),
      unitNumber: json['unit_number'] as String,
      propertyId: (json['property_id'] as num).toInt(),
      bedrooms: (json['bedrooms'] as num).toInt(),
      bathrooms: (json['bathrooms'] as num).toInt(),
      squareFeet: (json['square_feet'] as num?)?.toDouble(),
      monthlyRent: (json['monthly_rent'] as num).toDouble(),
      isOccupied: json['is_occupied'] as bool,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UnitModelToJson(UnitModel instance) => <String, dynamic>{
      'id': instance.id,
      'unit_number': instance.unitNumber,
      'property_id': instance.propertyId,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'square_feet': instance.squareFeet,
      'monthly_rent': instance.monthlyRent,
      'is_occupied': instance.isOccupied,
      'description': instance.description,
    };
