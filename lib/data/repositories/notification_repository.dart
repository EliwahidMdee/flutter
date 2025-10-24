import '../models/notification_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
class NotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int page = 1,
    int perPage = 15,
  }) async {
    final query = <String, dynamic>{
      if (isRead != null) 'is_read': isRead ? 1 : 0,
      'page': page,
      'per_page': perPage,
    };

    final response = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: query.isNotEmpty ? query : null,
    );

    final data = response.data['data'] as List? ?? [];
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _client.post(ApiEndpoints.markRead(notificationId));
    return NotificationModel.fromJson(response.data['data'] ?? response.data);
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
    try {
      // Call the notifications list endpoint without `count_only` to avoid server errors.
      final response = await _client.get(
        ApiEndpoints.notifications,
        queryParameters: {'is_read': 0},
      );

      final respData = response.data;

      // Preferred: check for pagination/meta.total (common API patterns)
      if (respData is Map) {
        // Some APIs return metadata under `meta` or `pagination` with `total` or `total_items`.
        final meta = respData['meta'] ?? respData['pagination'] ?? respData['paging'];
        if (meta is Map) {
          final totalCandidates = ['total', 'total_items', 'totalCount', 'total_count'];
          for (final key in totalCandidates) {
            if (meta.containsKey(key)) {
              final val = meta[key];
              if (val is num) return val.toInt();
              final parsed = int.tryParse(val.toString());
              if (parsed != null) return parsed;
            }
          }
        }

        // Some APIs include `total` at the top level
        for (final key in ['total', 'total_count', 'count']) {
          if (respData.containsKey(key)) {
            final val = respData[key];
            if (val is num) return val.toInt();
            final parsed = int.tryParse(val.toString());
            if (parsed != null) return parsed;
          }
        }

        // Fallback: if `data` is a list, count unread items returned in the response
        final dataList = respData['data'];
        if (dataList is List) {
          return dataList.length;
        }
      }

      // As a last fallback, try to parse the response body as an integer
      return int.tryParse(respData.toString()) ?? 0;
    } catch (e, st) {
      AppLogger.e('Failed to fetch unread count: $e\n$st');
      return 0;
    }
  }
}
