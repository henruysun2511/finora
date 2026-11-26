import '../../domain/models/notification_filter.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/models/notification_type.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mapper/notification_mapper.dart';
import '../services/notification_api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);
  final NotificationApiService _api;

  @override
  Future<List<NotificationItem>> getNotifications(
      NotificationFilter filter) async {
    try {
      final dtos = await _api.getNotifications(filter.toQueryMap());
      return dtos.map(NotificationMapper.toDomain).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      return await _api.getUnreadCount();
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllAsRead();
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }

  @override
  Future<NotificationItem> markAsRead(String id) async {
    try {
      final dto = await _api.markAsRead(id);
      return NotificationMapper.toDomain(dto);
    } catch (_) {
      return NotificationItem(
        id: id,
        userId: 'current',
        type: NotificationType.general,
        title: 'Thông báo',
        body: '',
        isRead: true,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _api.deleteNotification(id);
    } catch (_) {
      // Bỏ qua lỗi mạng
    }
  }
}

