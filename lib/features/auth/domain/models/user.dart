class User {
  final String id;
  final String email;
  final String name;
  final String? username;
  final String? phone;
  final String? avatarUrl;
  final String? role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    this.phone,
    this.avatarUrl,
    this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: (json['fullName'] ?? json['name']) as String? ?? 'Người dùng',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: (json['avatar'] ?? json['avatarUrl'] ?? json['avatar_url']) as String?,
      role: json['role'] as String? ??
          (json['roles'] is List && (json['roles'] as List).isNotEmpty
              ? (json['roles'] as List).first['name'] ?? (json['roles'] as List).first['code']
              : null),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'username': username,
        'phone': phone,
        'avatar_url': avatarUrl,
        'role': role,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? username,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
