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
  
  // Defensive fromJson to handle null/missing numeric fields coming from backend
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse ints safely with fallback
    int parseInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    double parseDouble(dynamic v, {double fallback = 0.0}) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? fallback;
    }

    final totalProperties = parseInt(json['total_properties']);
    final activeTenants = parseInt(json['active_tenants']);
    final pendingPayments = parseInt(json['pending_payments']);
    final monthlyRevenue = parseDouble(json['monthly_revenue']);

    final totalRevenue = json['total_revenue'] == null
        ? null
        : parseDouble(json['total_revenue'], fallback: 0.0);

    final occupiedUnits = json['occupied_units'] == null
        ? null
        : parseInt(json['occupied_units']);

    final totalUnits = json['total_units'] == null
        ? null
        : parseInt(json['total_units']);

    final occupancyRate = json['occupancy_rate'] == null
        ? null
        : parseDouble(json['occupancy_rate'], fallback: 0.0);

    List<ActivityModel>? recentActivities;
    final rawActivities = json['recent_activities'];
    if (rawActivities is List) {
      recentActivities = rawActivities
          .where((e) => e != null)
          .map((e) => ActivityModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      recentActivities = null;
    }

    return DashboardStatsModel(
      totalProperties: totalProperties,
      activeTenants: activeTenants,
      pendingPayments: pendingPayments,
      monthlyRevenue: monthlyRevenue,
      totalRevenue: totalRevenue,
      occupiedUnits: occupiedUnits,
      totalUnits: totalUnits,
      occupancyRate: occupancyRate,
      recentActivities: recentActivities,
    );
  }

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
