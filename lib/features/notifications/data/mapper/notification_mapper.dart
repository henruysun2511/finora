import '../../domain/models/notification_item.dart';
import '../../domain/models/notification_type.dart';
import '../dto/notification_response.dart';

class NotificationMapper {
  static NotificationItem toDomain(NotificationResponse dto) {
    return NotificationItem(
      id: dto.id,
      userId: dto.userId,
      type: NotificationType.fromBackend(dto.type),
      title: dto.title,
      body: dto.body,
      isRead: dto.isRead,
      relatedEntityType: dto.relatedEntityType,
      relatedEntityId: dto.relatedEntityId,
      actionUrl: dto.actionUrl,
      metadata: dto.metadata,
      readAt: dto.readAt != null ? DateTime.tryParse(dto.readAt!) : null,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
    );
  }
}

