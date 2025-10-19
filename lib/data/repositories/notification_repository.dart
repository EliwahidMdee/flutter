import '../models/notification_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  final ApiClient _client;
  
  NotificationRepository(this._client);
  
  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (isRead != null) queryParams['is_read'] = isRead ? 1 : 0;
    
    final response = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: queryParams,
    );
    
    final data = response.data['data'] as List;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }
  
  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _client.post(
      ApiEndpoints.markRead(notificationId),
    );
    
    return NotificationModel.fromJson(response.data['data']);
  }
  
  Future<void> markAllAsRead() async {
    await _client.post(ApiEndpoints.markAllRead);
  }
  
  Future<NotificationResponse> respondToNotification({
    required int notificationId,
    required String message,
  }) async {
    final response = await _client.post(
      ApiEndpoints.respondToNotification(notificationId),
      data: {
        'message': message,
      },
    );
    
    return NotificationResponse.fromJson(response.data['data']);
  }
  
  Future<int> getUnreadCount() async {
    final response = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'is_read': 0,
        'count_only': true,
      },
    );
    
    return response.data['count'] ?? 0;
  }
}
