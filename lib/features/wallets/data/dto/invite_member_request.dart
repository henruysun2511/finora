import '../../domain/enums/wallet_member_role.dart';

class InviteMemberRequest {
  final String email;
  final WalletMemberRole role;

  const InviteMemberRequest({
    required this.email,
    this.role = WalletMemberRole.viewer,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'role': role.toServerString(),
    };
  }
}

