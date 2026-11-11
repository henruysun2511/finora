/// DTO khớp với NotificationResponseDto của backend
class NotificationResponse {
  const NotificationResponse({
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
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final String? readAt;
  final String createdAt;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: json['relatedEntityId']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : null,
      readAt: json['readAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

