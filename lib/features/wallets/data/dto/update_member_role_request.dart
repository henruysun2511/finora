import '../../domain/enums/wallet_member_role.dart';

class UpdateMemberRoleRequest {
  final WalletMemberRole role;

  const UpdateMemberRoleRequest({
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role.toServerString(),
    };
  }
}

