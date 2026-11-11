import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../messages/presentation/screens/conversations_screen.dart';

/// Màn hình Tin nhắn P2P / Locket Chat
/// Được kết nối trực tiếp với module messages chuẩn Clean Architecture.
class SocialChatScreen extends StatelessWidget {
  const SocialChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConversationsScreen();
  }
}
