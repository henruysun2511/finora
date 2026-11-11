import '../../domain/models/friend.dart';

class FriendResponseDto {
  const FriendResponseDto({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.connectedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final String? connectedAt;

  factory FriendResponseDto.fromJson(Map<String, dynamic> json) {
    return FriendResponseDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      connectedAt: json['connectedAt'] as String?,
    );
  }

  Friend toDomain() {
    return Friend(
      id: id,
      fullName: fullName,
      email: email,
      avatar: avatar,
      connectedAt: connectedAt != null ? DateTime.tryParse(connectedAt!) : null,
    );
  }
}

