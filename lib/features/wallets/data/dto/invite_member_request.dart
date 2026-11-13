import '../../domain/enums/wallet_member_role.dart';

class InviteMemberRequest {
  final String? email;
  final String? userId;
  final WalletMemberRole role;

  const InviteMemberRequest({
    this.email,
    this.userId,
    this.role = WalletMemberRole.viewer,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null && email!.isNotEmpty) 'email': email!.trim(),
      if (userId != null && userId!.isNotEmpty) 'userId': userId!.trim(),
      'role': role.toServerString(),
    };
  }
}

