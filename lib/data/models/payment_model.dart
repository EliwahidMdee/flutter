import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  @JsonKey(name: 'tenant_id')
  final int tenantId;
  @JsonKey(name: 'property_id')
  final int? propertyId;
  @JsonKey(name: 'lease_id')
  final int? leaseId;
  final double amount;
  @JsonKey(name: 'payment_date')
  final String paymentDate;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String status;  // pending, paid, rejected
  final String? notes;
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Relationships
  final TenantInfo? tenant;
  final PropertyInfo? property;
  
  PaymentModel({
    required this.id,
    required this.tenantId,
    this.propertyId,
    this.leaseId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.referenceNumber,
    required this.createdAt,
    this.updatedAt,
    this.tenant,
    this.property,
  });
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
  
  // Helpers
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isRejected => status.toLowerCase() == 'rejected';
  
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Approval';
      case 'paid':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }
  
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

@JsonSerializable()
class TenantInfo {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  
  TenantInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
  });
  
  factory TenantInfo.fromJson(Map<String, dynamic> json) =>
      _$TenantInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$TenantInfoToJson(this);
}

@JsonSerializable()
class PropertyInfo {
  final int id;
  final String name;
  final String? address;
  
  PropertyInfo({
    required this.id,
    required this.name,
    this.address,
  });
  
  factory PropertyInfo.fromJson(Map<String, dynamic> json) =>
      _$PropertyInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$PropertyInfoToJson(this);
}
