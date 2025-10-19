import 'package:flutter/foundation.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository;
  
  NotificationStatus _status = NotificationStatus.initial;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _error;
  
  NotificationProvider(this._repository);
  
  // Getters
  NotificationStatus get status => _status;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get error => _error;
  bool get isLoading => _status == NotificationStatus.loading;
  
  // Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }
  
  // Fetch notifications
  Future<void> fetchNotifications({bool? isRead}) async {
    _status = NotificationStatus.loading;
    notifyListeners();
    
    try {
      _notifications = await _repository.getNotifications(isRead: isRead);
      _status = NotificationStatus.loaded;
      _error = null;
      
      // Update unread count
      await fetchUnreadCount();
    } catch (e) {
      _status = NotificationStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }
  
  // Mark as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Refresh notifications
        await fetchNotifications();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await fetchNotifications();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Respond to notification
  Future<bool> respondToNotification({
    required int notificationId,
    required String message,
  }) async {
    try {
      await _repository.respondToNotification(
        notificationId: notificationId,
        message: message,
      );
      
      // Refresh notifications to get updated responses
      await fetchNotifications();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
