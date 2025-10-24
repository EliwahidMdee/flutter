// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalProperties: (json['total_properties'] as num).toInt(),
      activeTenants: (json['active_tenants'] as num).toInt(),
      pendingPayments: (json['pending_payments'] as num).toInt(),
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble(),
      occupiedUnits: (json['occupied_units'] as num?)?.toInt(),
      totalUnits: (json['total_units'] as num?)?.toInt(),
      occupancyRate: (json['occupancy_rate'] as num?)?.toDouble(),
      recentActivities: (json['recent_activities'] as List<dynamic>?)
          ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
        DashboardStatsModel instance) =>
    <String, dynamic>{
      'total_properties': instance.totalProperties,
      'active_tenants': instance.activeTenants,
      'pending_payments': instance.pendingPayments,
      'monthly_revenue': instance.monthlyRevenue,
      'total_revenue': instance.totalRevenue,
      'occupied_units': instance.occupiedUnits,
      'total_units': instance.totalUnits,
      'occupancy_rate': instance.occupancyRate,
      'recent_activities': instance.recentActivities,
    };

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timeAgo: json['time_ago'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'time_ago': instance.timeAgo,
      'created_at': instance.createdAt,
    };
