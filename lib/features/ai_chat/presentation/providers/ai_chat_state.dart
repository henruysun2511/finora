import 'package:flutter/foundation.dart';

import '../../../../core/widgets/mascot/mascot_model.dart';
import '../../../../core/widgets/mascot/mascot_registry.dart';
import '../../domain/models/chat_message_model.dart';
import '../../domain/models/wallet_item_model.dart';

@immutable
class AiChatState {
  final List<ChatMessageModel> messages;
  final bool isLoadingHistory;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isSending;
  final String? activeWalletId;
  final String activeWalletName;
  final List<WalletItemModel> wallets;
  final String mascotId;
  final String? errorMessage;

  const AiChatState({
    this.messages = const [],
    this.isLoadingHistory = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSending = false,
    this.activeWalletId,
    this.activeWalletName = 'Ví Chi Tiêu Cá Nhân',
    this.wallets = const [],
    this.mascotId = 'nora',
    this.errorMessage,
  });

  MascotData get mascotData {
    switch (mascotId.toLowerCase().trim()) {
      case 'ash':
        return MascotRegistry.ash;
      case 'penny':
        return MascotRegistry.penny;
      case 'sage':
        return MascotRegistry.sage;
      case 'jade':
        return MascotRegistry.jade;
      case 'ruby':
        return MascotRegistry.ruby;
      case 'bellingham':
        return MascotRegistry.bellingham;
      case 'nora':
      default:
        return MascotRegistry.nora;
    }
  }

  AiChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoadingHistory,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSending,
    String? activeWalletId,
    String? activeWalletName,
    List<WalletItemModel>? wallets,
    String? mascotId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      activeWalletId: activeWalletId ?? this.activeWalletId,
      activeWalletName: activeWalletName ?? this.activeWalletName,
      wallets: wallets ?? this.wallets,
      mascotId: mascotId ?? this.mascotId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
