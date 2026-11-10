import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_filter.dart';
import '../../domain/models/notification_item.dart';
import 'notification_providers.dart';

// ─── Filter Provider ─────────────────────────────────────────────────────────

final notificationFilterProvider =
    StateProvider.autoDispose<NotificationFilter>((ref) {
  return const NotificationFilter();
});

// ─── List Provider ────────────────────────────────────────────────────────────

final notificationListProvider = AsyncNotifierProvider.autoDispose<
    NotificationListNotifier, List<NotificationItem>>(() {
  return NotificationListNotifier();
});

class NotificationListNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    final filter = ref.watch(notificationFilterProvider);
    final repo = ref.read(notificationRepositoryProvider);
    return repo.getNotifications(filter);
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true, readAt: DateTime.now());
        }
        return item;
      }).toList());
    }
    await repo.markAsRead(id);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current
            .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
            .toList(),
      );
    }
    await repo.markAllAsRead();
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> delete(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((item) => item.id != id).toList());
    }
    await repo.deleteNotification(id);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    ref.invalidate(unreadNotificationCountProvider);
  }
}

// ─── Unread Count Provider ───────────────────────────────────────────────────

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final list = ref.watch(notificationListProvider).valueOrNull;
  if (list != null) {
    return list.where((item) => !item.isRead).length;
  }
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

