import '../models/notification_item.dart';
import '../models/notification_filter.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> getNotifications(NotificationFilter filter);
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();
  Future<NotificationItem> markAsRead(String id);
  Future<void> deleteNotification(String id);
}

