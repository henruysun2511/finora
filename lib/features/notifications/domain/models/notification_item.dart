import 'notification_type.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.relatedEntityType,
    this.relatedEntityId,
    this.actionUrl,
    this.metadata,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationItem copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    String? relatedEntityType,
    String? relatedEntityId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

