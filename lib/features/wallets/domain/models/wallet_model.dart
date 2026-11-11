import '../enums/wallet_member_role.dart';

class WalletModel {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  final String defaultCurrency;
  final bool isShared;
  final bool isActive;
  final String ownerId;
  final WalletMemberRole currentUserRole;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    required this.defaultCurrency,
    required this.isShared,
    required this.isActive,
    required this.ownerId,
    required this.currentUserRole,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOwner => currentUserRole == WalletMemberRole.owner;
  bool get canEdit =>
      currentUserRole == WalletMemberRole.owner ||
      currentUserRole == WalletMemberRole.editor;
  bool get isPersonal => !isShared;
  int get accountsCount => 3;
  int get memberCount => isShared ? 4 : 1;

  WalletModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    String? defaultCurrency,
    bool? isShared,
    bool? isActive,
    String? ownerId,
    WalletMemberRole? currentUserRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      isShared: isShared ?? this.isShared,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

