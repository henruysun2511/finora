class UpdateWalletRequest {
  final String? name;
  final String? icon;
  final String? description;
  final bool? isShared;

  const UpdateWalletRequest({
    this.name,
    this.icon,
    this.description,
    this.isShared,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name!.trim(),
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description!.trim(),
      if (isShared != null) 'isShared': isShared,
    };
  }
}

