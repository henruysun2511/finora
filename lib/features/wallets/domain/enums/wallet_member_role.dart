import 'package:flutter/material.dart';

enum WalletMemberRole {
  owner,
  editor,
  viewer;

  static WalletMemberRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return WalletMemberRole.owner;
      case 'editor':
        return WalletMemberRole.editor;
      case 'viewer':
      default:
        return WalletMemberRole.viewer;
    }
  }

  String toServerString() {
    switch (this) {
      case WalletMemberRole.owner:
        return 'owner';
      case WalletMemberRole.editor:
        return 'editor';
      case WalletMemberRole.viewer:
        return 'viewer';
    }
  }

  String get displayName {
    switch (this) {
      case WalletMemberRole.owner:
        return 'Chủ sở hữu';
      case WalletMemberRole.editor:
        return 'Biên tập viên';
      case WalletMemberRole.viewer:
        return 'Người xem';
    }
  }

  Color get badgeColor {
    switch (this) {
      case WalletMemberRole.owner:
        return const Color(0xFF6366F1); // Indigo
      case WalletMemberRole.editor:
        return const Color(0xFF10B981); // Emerald Green
      case WalletMemberRole.viewer:
        return const Color(0xFF64748B); // Slate Gray
    }
  }

  IconData get icon {
    switch (this) {
      case WalletMemberRole.owner:
        return Icons.star_rounded;
      case WalletMemberRole.editor:
        return Icons.edit_note_rounded;
      case WalletMemberRole.viewer:
        return Icons.visibility_rounded;
    }
  }
}

