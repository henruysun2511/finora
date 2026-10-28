import 'package:flutter/foundation.dart';

enum ChatRoleEnum {
  user,
  assistant;

  static ChatRoleEnum fromString(String? val) {
    if (val?.toUpperCase() == 'USER') return ChatRoleEnum.user;
    return ChatRoleEnum.assistant;
  }

  String toApiString() => this == ChatRoleEnum.user ? 'USER' : 'ASSISTANT';
}

enum ChatMessageTypeEnum {
  text,
  confirmationPrompt,
  statCard,
  chartPie,
  chartBar,
  transactionList,
  other;

  static ChatMessageTypeEnum fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'TEXT':
        return ChatMessageTypeEnum.text;
      case 'CONFIRMATION_PROMPT':
      case 'TRANSACTION_CONFIRMATION':
        return ChatMessageTypeEnum.confirmationPrompt;
      case 'STAT_CARD':
        return ChatMessageTypeEnum.statCard;
      case 'CHART_PIE':
        return ChatMessageTypeEnum.chartPie;
      case 'CHART_BAR':
      case 'CHART':
        return ChatMessageTypeEnum.chartBar;
      case 'TRANSACTION_LIST':
        return ChatMessageTypeEnum.transactionList;
      default:
        return ChatMessageTypeEnum.other;
    }
  }
}

enum PendingActionStatusEnum {
  pending,
  confirmed,
  rejected,
  expired;

  static PendingActionStatusEnum fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'CONFIRMED':
        return PendingActionStatusEnum.confirmed;
      case 'REJECTED':
        return PendingActionStatusEnum.rejected;
      case 'EXPIRED':
        return PendingActionStatusEnum.expired;
      case 'PENDING':
      default:
        return PendingActionStatusEnum.pending;
    }
  }

  String toApiString() => name.toUpperCase();
}

@immutable
class PendingActionSummary {
  final String id;
  final PendingActionStatusEnum status;
  final DateTime? expiresAt;
  final String? transactionId;

  const PendingActionSummary({
    required this.id,
    required this.status,
    this.expiresAt,
    this.transactionId,
  });

  factory PendingActionSummary.fromJson(Map<String, dynamic> json) {
    return PendingActionSummary(
      id: json['id'] as String? ?? '',
      status: PendingActionStatusEnum.fromString(json['status'] as String?),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      transactionId: json['transactionId'] as String?,
    );
  }

  PendingActionSummary copyWith({
    String? id,
    PendingActionStatusEnum? status,
    DateTime? expiresAt,
    String? transactionId,
  }) {
    return PendingActionSummary(
      id: id ?? this.id,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}

@immutable
class ChatMessageModel {
  final String id;
  final ChatRoleEnum role;
  final ChatMessageTypeEnum messageType;
  final String textContent;
  final String? intent;
  final String? mascot;
  final Map<String, dynamic>? payloadJson;
  final PendingActionSummary? pendingAction;
  final DateTime createdAt;
  final Uint8List? mediaBytes;
  final String? mediaType; // 'image' | 'audio'
  final bool hasError;
  final String? errorMessage;
  final List<int>? retryBytes;
  final String? retryFilename;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.messageType,
    required this.textContent,
    this.intent,
    this.mascot,
    this.payloadJson,
    this.pendingAction,
    required this.createdAt,
    this.mediaBytes,
    this.mediaType,
    this.hasError = false,
    this.errorMessage,
    this.retryBytes,
    this.retryFilename,
  });

  bool get isUser => role == ChatRoleEnum.user;
  bool get isAssistant => role == ChatRoleEnum.assistant;
  bool get isConfirmationPrompt {
    if (payloadJson != null && payloadJson!['result'] != null) {
      return false;
    }
    if (messageType == ChatMessageTypeEnum.confirmationPrompt) {
      return true;
    }
    if (pendingAction != null &&
        payloadJson != null &&
        (payloadJson!.containsKey('preview') ||
            payloadJson!.containsKey('toolInput') ||
            payloadJson!.containsKey('amount'))) {
      return true;
    }
    return false;
  }

  bool get hasImage =>
      mediaType == 'image' ||
      (mediaBytes != null && mediaType == 'image') ||
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (payloadJson?['input'] == 'receipt');

  String? get imageUrl {
    final rootImg = payloadJson?['imageUrl'] as String? ??
        payloadJson?['photoUrl'] as String?;
    if (rootImg != null && rootImg.isNotEmpty) return rootImg;

    final preview = payloadJson?['preview'];
    if (preview is Map) {
      final pImg = preview['photoUrl'] as String? ??
          preview['imageUrl'] as String? ??
          preview['receiptUrl'] as String?;
      if (pImg != null && pImg.isNotEmpty) return pImg;
    }

    final toolInput = payloadJson?['toolInput'];
    if (toolInput is Map) {
      final tImg = toolInput['photoUrl'] as String? ??
          toolInput['imageUrl'] as String? ??
          toolInput['receiptUrl'] as String?;
      if (tImg != null && tImg.isNotEmpty) return tImg;
    }

    return null;
  }

  bool get hasAudio =>
      mediaType == 'audio' ||
      (mediaBytes != null && mediaType == 'audio') ||
      (payloadJson?['input'] == 'voice') ||
      (audioUrl != null && audioUrl!.isNotEmpty);

  String? get audioUrl {
    final rootAudio = payloadJson?['audioUrl'] as String?;
    if (rootAudio != null && rootAudio.isNotEmpty) return rootAudio;

    final preview = payloadJson?['preview'];
    if (preview is Map) {
      final pAudio = preview['audioUrl'] as String?;
      if (pAudio != null && pAudio.isNotEmpty) return pAudio;
    }

    final toolInput = payloadJson?['toolInput'];
    if (toolInput is Map) {
      final tAudio = toolInput['audioUrl'] as String?;
      if (tAudio != null && tAudio.isNotEmpty) return tAudio;
    }

    return null;
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payloadJson'];
    Map<String, dynamic>? payloadMap;
    if (rawPayload is Map) {
      payloadMap = Map<String, dynamic>.from(rawPayload);
    }

    final rawPendingAction = json['pendingAction'];
    PendingActionSummary? pendingActionSummary;
    if (rawPendingAction is Map) {
      pendingActionSummary = PendingActionSummary.fromJson(
        Map<String, dynamic>.from(rawPendingAction),
      );
    } else if (payloadMap != null &&
        payloadMap['pendingActionId'] != null &&
        payloadMap['result'] == null &&
        (payloadMap.containsKey('preview') ||
            payloadMap.containsKey('toolInput') ||
            payloadMap.containsKey('amount'))) {
      pendingActionSummary = PendingActionSummary(
        id: payloadMap['pendingActionId'].toString(),
        status: PendingActionStatusEnum.pending,
      );
    }

    String? resolvedMediaType;
    if (payloadMap != null) {
      if (payloadMap['imageUrl'] != null ||
          payloadMap['photoUrl'] != null ||
          payloadMap['input'] == 'receipt') {
        resolvedMediaType = 'image';
      } else if (payloadMap['audioUrl'] != null ||
          payloadMap['input'] == 'voice') {
        resolvedMediaType = 'audio';
      }
    }

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      role: ChatRoleEnum.fromString(json['role'] as String?),
      messageType:
          ChatMessageTypeEnum.fromString(json['messageType'] as String?),
      textContent: json['textContent'] as String? ?? '',
      intent: json['intent'] as String?,
      mascot: json['mascot'] as String?,
      payloadJson: payloadMap,
      pendingAction: pendingActionSummary,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      mediaType: resolvedMediaType,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    ChatRoleEnum? role,
    ChatMessageTypeEnum? messageType,
    String? textContent,
    String? intent,
    String? mascot,
    Map<String, dynamic>? payloadJson,
    PendingActionSummary? pendingAction,
    DateTime? createdAt,
    Uint8List? mediaBytes,
    String? mediaType,
    bool? hasError,
    String? errorMessage,
    List<int>? retryBytes,
    String? retryFilename,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      messageType: messageType ?? this.messageType,
      textContent: textContent ?? this.textContent,
      intent: intent ?? this.intent,
      mascot: mascot ?? this.mascot,
      payloadJson: payloadJson ?? this.payloadJson,
      pendingAction: pendingAction ?? this.pendingAction,
      createdAt: createdAt ?? this.createdAt,
      mediaBytes: mediaBytes ?? this.mediaBytes,
      mediaType: mediaType ?? this.mediaType,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      retryBytes: retryBytes ?? this.retryBytes,
      retryFilename: retryFilename ?? this.retryFilename,
    );
  }
}

