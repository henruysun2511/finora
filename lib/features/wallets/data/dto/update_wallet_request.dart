class UpdateWalletRequest {
  final String? name;
  final String? icon;
  final String? description;

  const UpdateWalletRequest({
    this.name,
    this.icon,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name!.trim(),
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description!.trim(),
    };
  }
}

