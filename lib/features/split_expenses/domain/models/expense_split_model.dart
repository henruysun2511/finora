import 'split_enums.dart';
import 'split_participant_model.dart';

class ExpenseSplitModel {
  const ExpenseSplitModel({
    required this.id,
    required this.transactionId,
    required this.walletId,
    required this.createdById,
    this.creatorName,
    required this.totalAmount,
    required this.splitType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
  });

  final String id;
  final String transactionId;
  final String walletId;
  final String createdById;
  final String? creatorName;
  final double totalAmount;
  final SplitType splitType;
  final SplitStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SplitParticipantModel> participants;

  bool isOwner(String? currentUserId) =>
      currentUserId != null && currentUserId == createdById;

  bool get isPending => status == SplitStatus.pending;
  bool get isAllAccepted => status == SplitStatus.allAccepted;
  bool get isConfirmed => status == SplitStatus.confirmed;
  bool get isCancelled => status == SplitStatus.cancelled;

  /// Danh sách bạn bè tham gia (không bao gồm chủ chi)
  List<SplitParticipantModel> get friendParticipants =>
      participants.where((p) => p.userId != createdById).toList();

  /// Bản ghi phân bổ của chính chủ chi
  SplitParticipantModel? get ownerParticipant =>
      participants.where((p) => p.userId == createdById).firstOrNull;

  /// Số bạn bè đã đồng ý
  int get acceptedFriendsCount =>
      friendParticipants.where((p) => p.status == ParticipantStatus.accepted).length;

  /// Tỷ lệ đồng thuận từ 0.0 đến 1.0
  double get consensusRate {
    if (friendParticipants.isEmpty) return 1.0;
    return acceptedFriendsCount / friendParticipants.length;
  }

  /// Có bạn bè nào phản đối hoặc đề xuất lại không
  bool get hasIssues => friendParticipants.any(
        (p) =>
            p.status == ParticipantStatus.rejected ||
            p.status == ParticipantStatus.proposed,
      );

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];
    final List<SplitParticipantModel> participantsList = [];
    if (rawParticipants is List) {
      for (final item in rawParticipants) {
        if (item is Map<String, dynamic>) {
          participantsList.add(SplitParticipantModel.fromJson(item));
        }
      }
    }

    return ExpenseSplitModel(
      id: json['id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      walletId: json['walletId'] as String? ?? '',
      createdById: json['createdById'] as String? ?? '',
      creatorName: json['creatorName'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      splitType: SplitType.fromString(json['splitType'] as String? ?? ''),
      status: SplitStatus.fromString(json['status'] as String? ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      participants: participantsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'walletId': walletId,
      'createdById': createdById,
      'creatorName': creatorName,
      'totalAmount': totalAmount,
      'splitType': splitType.value,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
    };
  }
}
