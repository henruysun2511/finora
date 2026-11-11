import 'notification_type.dart';

class NotificationFilter {
  const NotificationFilter({
    this.isRead,
    this.type,
    this.page = 1,
    this.limit = 20,
  });

  final bool? isRead;
  final NotificationType? type;
  final int page;
  final int limit;

  NotificationFilter copyWith({
    bool? isRead,
    NotificationType? type,
    bool clearRead = false,
    bool clearType = false,
    int? page,
    int? limit,
  }) {
    return NotificationFilter(
      isRead: clearRead ? null : (isRead ?? this.isRead),
      type: clearType ? null : (type ?? this.type),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryMap() {
    return {
      if (isRead != null) 'isRead': isRead,
      if (type != null) 'type': type!.backendValue,
      'page': page,
      'limit': limit,
    };
  }
}

