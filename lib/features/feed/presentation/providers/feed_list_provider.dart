import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/feed_query.dart';
import '../../domain/models/post_reaction.dart';
import '../../domain/models/reaction_emoji.dart';
import 'feed_providers.dart';

// Filter state: 0 = Tất cả, 1 = Bạn bè, 2 = Của tôi
final feedTabFilterProvider = StateProvider.autoDispose<int>((ref) => 0);

final feedSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

enum FeedViewMode { list, grid }

final feedViewModeProvider =
    StateProvider<FeedViewMode>((ref) => FeedViewMode.list);

final feedListProvider =
    AsyncNotifierProvider.autoDispose<FeedListNotifier, List<FeedPost>>(() {
  return FeedListNotifier();
});

class FeedListNotifier extends AutoDisposeAsyncNotifier<List<FeedPost>> {
  @override
  Future<List<FeedPost>> build() async {
    final repo = ref.read(feedRepositoryProvider);
    return repo.getFeed(query: const FeedQuery(page: 1, limit: 20));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedRepositoryProvider);
      return repo.getFeed(query: const FeedQuery(page: 1, limit: 20));
    });
  }

  /// Thả hoặc gỡ cảm xúc với Optimistic UI
  Future<void> toggleReaction(
    String transactionId, {
    ReactionEmoji? emoji,
    String? symbol,
    String? label,
  }) async {
    final repo = ref.read(feedRepositoryProvider);
    final currentList = state.value;
    if (currentList == null) return;

    final isRemoving = emoji == null;

    // 1. Optimistic Update
    state = AsyncData(currentList.map((post) {
      if (post.id == transactionId) {
        if (isRemoving) {
          final newCount =
              post.reactionsCount > 0 ? post.reactionsCount - 1 : 0;
          return post.copyWith(
            reactionsCount: newCount,
            clearMyReaction: true,
          );
        } else {
          final wasReacted = post.hasReacted;
          final newCount =
              wasReacted ? post.reactionsCount : post.reactionsCount + 1;
          return post.copyWith(
            reactionsCount: newCount,
            myReaction: emoji,
            myReactionSymbol: symbol ?? emoji.symbol,
            myReactionLabel: label ?? emoji.label,
          );
        }
      }
      return post;
    }).toList());

    // 2. Gọi API Backend
    try {
      if (isRemoving) {
        await repo.removeReaction(transactionId);
      } else {
        await repo.addReaction(transactionId: transactionId, emoji: emoji);
      }
    } catch (_) {
      // Revert if API fails
      state = AsyncData(currentList);
    }
  }

  /// Lấy danh sách người đã thả cảm xúc
  Future<List<PostReaction>> getReactions(String transactionId) async {
    final repo = ref.read(feedRepositoryProvider);
    return repo.getReactions(transactionId);
  }

  /// Cập nhật bài đăng (ẩn/hiện số tiền, caption, v.v.)
  Future<void> updatePost({
    required String transactionId,
    String? visibility,
    bool? amountHidden,
    String? note,
  }) async {
    final repo = ref.read(feedRepositoryProvider);
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistic UI update
    state = AsyncData(currentList.map((post) {
      if (post.id == transactionId) {
        return post.copyWith(
          isAmountHidden: amountHidden ?? post.isAmountHidden,
          note: note ?? post.note,
        );
      }
      return post;
    }).toList());

    try {
      await repo.updatePost(
        transactionId: transactionId,
        visibility: visibility,
        amountHidden: amountHidden,
        note: note,
      );
    } catch (_) {
      state = AsyncData(currentList);
    }
  }
}

