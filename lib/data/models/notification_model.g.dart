// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
      relatedId: (json['related_id'] as num?)?.toInt(),
      canRespond: json['can_respond'] as bool?,
      responses: (json['responses'] as List<dynamic>?)
          ?.map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
      readAt: json['read_at'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'is_read': instance.isRead,
      'related_id': instance.relatedId,
      'can_respond': instance.canRespond,
      'responses': instance.responses,
      'created_at': instance.createdAt,
      'read_at': instance.readAt,
    };

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      id: (json['id'] as num).toInt(),
      notificationId: (json['notification_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      message: json['message'] as String,
      userName: json['user_name'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notification_id': instance.notificationId,
      'user_id': instance.userId,
      'message': instance.message,
      'user_name': instance.userName,
      'created_at': instance.createdAt,
    };
