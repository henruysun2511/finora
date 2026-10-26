import 'chat_message_model.dart';

class PendingActionDetailModel {
  final String id;
  final String toolName;
  final Map<String, dynamic> toolInput;
  final Map<String, dynamic> previewPayload;
  final PendingActionStatusEnum status;
  final String? transactionId;
  final DateTime expiresAt;
  final DateTime createdAt;
  final ChatMessageModel? assistantMessage;

  const PendingActionDetailModel({
    required this.id,
    required this.toolName,
    required this.toolInput,
    required this.previewPayload,
    required this.status,
    this.transactionId,
    required this.expiresAt,
    required this.createdAt,
    this.assistantMessage,
  });

  factory PendingActionDetailModel.fromJson(Map<String, dynamic> json) {
    return PendingActionDetailModel(
      id: json['id'] as String? ?? '',
      toolName: json['toolName'] as String? ?? '',
      toolInput: json['toolInput'] is Map
          ? Map<String, dynamic>.from(json['toolInput'] as Map)
          : {},
      previewPayload: json['previewPayload'] is Map
          ? Map<String, dynamic>.from(json['previewPayload'] as Map)
          : {},
      status: PendingActionStatusEnum.fromString(json['status'] as String?),
      transactionId: json['transactionId'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      assistantMessage: json['assistantMessage'] is Map
          ? ChatMessageModel.fromJson(
              Map<String, dynamic>.from(json['assistantMessage'] as Map))
          : null,
    );
  }
}
