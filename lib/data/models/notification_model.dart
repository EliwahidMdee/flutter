import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String title;
  final String message;
  final String type;  // payment, lease, maintenance, announcement
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'related_id')
  final int? relatedId;  // ID of related payment, lease, etc.
  @JsonKey(name: 'can_respond')
  final bool? canRespond;  // Whether user can respond to this notification
  final List<NotificationResponse>? responses;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'read_at')
  final String? readAt;
  
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedId,
    this.canRespond,
    this.responses,
    required this.createdAt,
    this.readAt,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
  
  // Helper to get time ago
  String get timeAgo {
    final now = DateTime.now();
    final created = DateTime.parse(createdAt);
    final difference = now.difference(created);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

@JsonSerializable()
class NotificationResponse {
  final int id;
  @JsonKey(name: 'notification_id')
  final int notificationId;
  @JsonKey(name: 'user_id')
  final int userId;
  final String message;
  @JsonKey(name: 'user_name')
  final String? userName;
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  NotificationResponse({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.message,
    this.userName,
    required this.createdAt,
  });
  
  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
