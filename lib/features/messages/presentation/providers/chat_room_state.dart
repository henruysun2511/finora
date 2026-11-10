import '../../domain/models/message.dart';

class ChatRoomState {
  const ChatRoomState({
    required this.messages,
    this.isSending = false,
    this.errorMessage,
  });

  final List<Message> messages;
  final bool isSending;
  final String? errorMessage;

  ChatRoomState copyWith({
    List<Message>? messages,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

