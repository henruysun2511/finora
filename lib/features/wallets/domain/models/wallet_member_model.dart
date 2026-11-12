import '../enums/wallet_member_role.dart';

class WalletMemberModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? avatar;
  final WalletMemberRole role;
  final String status;
  final DateTime? joinedAt;
  final DateTime createdAt;

  const WalletMemberModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.role,
    required this.status,
    this.joinedAt,
    required this.createdAt,
  });

  bool get isOwner => role == WalletMemberRole.owner;
  bool get isEditor => role == WalletMemberRole.editor;
  bool get isViewer => role == WalletMemberRole.viewer;
  String get userName => fullName;
}

