import 'split_enums.dart';

class SplitParticipantModel {
  const SplitParticipantModel({
    required this.id,
    required this.splitId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.assignedAmount,
    this.proposedAmount,
    required this.status,
    this.note,
    this.loanId,
    required this.isSettled,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String splitId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final double assignedAmount;
  final double? proposedAmount;
  final ParticipantStatus status;
  final String? note;
  final String? loanId;
  final bool isSettled;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => userName?.isNotEmpty == true ? userName! : 'Bạn bè';

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory SplitParticipantModel.fromJson(Map<String, dynamic> json) {
    return SplitParticipantModel(
      id: json['id'] as String? ?? '',
      splitId: json['splitId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      assignedAmount: (json['assignedAmount'] as num?)?.toDouble() ?? 0.0,
      proposedAmount: (json['proposedAmount'] as num?)?.toDouble(),
      status: ParticipantStatus.fromString(json['status'] as String? ?? ''),
      note: json['note'] as String?,
      loanId: json['loanId'] as String?,
      isSettled: json['isSettled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'splitId': splitId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'assignedAmount': assignedAmount,
      'proposedAmount': proposedAmount,
      'status': status.value,
      'note': note,
      'loanId': loanId,
      'isSettled': isSettled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SplitParticipantModel copyWith({
    String? id,
    String? splitId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? assignedAmount,
    double? proposedAmount,
    ParticipantStatus? status,
    String? note,
    String? loanId,
    bool? isSettled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitParticipantModel(
      id: id ?? this.id,
      splitId: splitId ?? this.splitId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      assignedAmount: assignedAmount ?? this.assignedAmount,
      proposedAmount: proposedAmount ?? this.proposedAmount,
      status: status ?? this.status,
      note: note ?? this.note,
      loanId: loanId ?? this.loanId,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
