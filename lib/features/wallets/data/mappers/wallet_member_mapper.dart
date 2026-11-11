import '../../domain/enums/wallet_member_role.dart';
import '../../domain/models/wallet_member_model.dart';

class WalletMemberMapper {
  WalletMemberMapper._();

  static WalletMemberModel fromJson(Map<String, dynamic> json) {
    return WalletMemberModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Thành viên',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: WalletMemberRole.fromString(json['role'] as String?),
      status: json['status'] as String? ?? 'ACCEPTED',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

