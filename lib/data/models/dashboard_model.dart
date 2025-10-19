import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardStatsModel {
  @JsonKey(name: 'total_properties')
  final int totalProperties;
  @JsonKey(name: 'active_tenants')
  final int activeTenants;
  @JsonKey(name: 'pending_payments')
  final int pendingPayments;
  @JsonKey(name: 'monthly_revenue')
  final double monthlyRevenue;
  @JsonKey(name: 'total_revenue')
  final double? totalRevenue;
  @JsonKey(name: 'occupied_units')
  final int? occupiedUnits;
  @JsonKey(name: 'total_units')
  final int? totalUnits;
  @JsonKey(name: 'occupancy_rate')
  final double? occupancyRate;
  @JsonKey(name: 'recent_activities')
  final List<ActivityModel>? recentActivities;
  
  DashboardStatsModel({
    required this.totalProperties,
    required this.activeTenants,
    required this.pendingPayments,
    required this.monthlyRevenue,
    this.totalRevenue,
    this.occupiedUnits,
    this.totalUnits,
    this.occupancyRate,
    this.recentActivities,
  });
  
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);
}

@JsonSerializable()
class ActivityModel {
  final int id;
  final String type;  // payment, tenant, property, etc.
  final String title;
  final String description;
  @JsonKey(name: 'time_ago')
  final String timeAgo;
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.createdAt,
  });
  
  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);
}
