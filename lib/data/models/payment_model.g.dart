// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int,
      propertyId: json['property_id'] as int?,
      leaseId: json['lease_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: json['payment_date'] as String,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      referenceNumber: json['reference_number'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      tenant: json['tenant'] == null
          ? null
          : TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>),
      property: json['property'] == null
          ? null
          : PropertyInfo.fromJson(json['property'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'property_id': instance.propertyId,
      'lease_id': instance.leaseId,
      'amount': instance.amount,
      'payment_date': instance.paymentDate,
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'notes': instance.notes,
      'reference_number': instance.referenceNumber,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'tenant': instance.tenant,
      'property': instance.property,
    };

TenantInfo _$TenantInfoFromJson(Map<String, dynamic> json) => TenantInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$TenantInfoToJson(TenantInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

PropertyInfo _$PropertyInfoFromJson(Map<String, dynamic> json) => PropertyInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$PropertyInfoToJson(PropertyInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
    };
