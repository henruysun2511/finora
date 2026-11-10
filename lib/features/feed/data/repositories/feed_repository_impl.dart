import '../../domain/models/feed_author.dart';
import '../../domain/models/feed_category.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/feed_query.dart';
import '../../domain/models/post_reaction.dart';
import '../../domain/models/reaction_emoji.dart';
import '../../domain/repositories/feed_repository.dart';
import '../dto/update_feed_post_request.dart';
import '../mapper/feed_mapper.dart';
import '../services/feed_api_service.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._api, {this.mapper = const FeedMapper()});

  final FeedApiService _api;
  final FeedMapper mapper;

  // Cache fallback items in-memory so optimistic or local changes persist across tabs
  final List<FeedPost> _inMemoryFallback = [
    FeedPost(
      id: 'tx-mock-1',
      author: const FeedAuthor(
        id: 'u-tran-ngoc',
        fullName: 'Trần Ngọc',
        username: 'tranngoc',
        avatar: null,
      ),
      name: 'Bún bò Huế trưa nay',
      category: const FeedCategory(
        id: 'cat-food',
        name: 'Ăn uống',
        icon: 'utensils',
        color: '#F59E0B',
      ),
      amount: -85000,
      currency: 'VND',
      isAmountHidden: false,
      note: 'Bún bò Huế quán quen, chia bill cùng team trưa nay 🍜',
      photoUrl:
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800&auto=format&fit=crop&q=80',
      locationName: 'Bếp Xanh Quán',
      transactionDate: DateTime.now().subtract(const Duration(minutes: 5)),
      reactionsCount: 16,
      topReactions: const [ReactionEmoji.love, ReactionEmoji.like, ReactionEmoji.haha],
      myReaction: ReactionEmoji.love,
    ),
    FeedPost(
      id: 'tx-mock-2',
      author: const FeedAuthor(
        id: 'u-hung-minh',
        fullName: 'Hùng Minh',
        username: 'hungminh',
        avatar: null,
      ),
      name: 'Lương tháng 8',
      category: const FeedCategory(
        id: 'cat-income',
        name: 'Thu nhập',
        icon: 'wallet',
        color: '#10B981',
      ),
      amount: 15000000,
      currency: 'VND',
      isAmountHidden: false,
      note: 'Nhận lương tháng 8 rồi! Trích tiết kiệm ngay 30% vào hũ Finora 💰🎉',
      photoUrl:
          'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&auto=format&fit=crop&q=80',
      locationName: 'Tech Corp',
      transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
      reactionsCount: 32,
      topReactions: const [ReactionEmoji.clap, ReactionEmoji.love, ReactionEmoji.wow],
      myReaction: ReactionEmoji.clap,
    ),
    FeedPost(
      id: 'tx-mock-3',
      author: const FeedAuthor(
        id: 'u-pham-lan',
        fullName: 'Phạm Lan',
        username: 'phamlan',
        avatar: null,
      ),
      name: 'Vé máy bay Đà Lạt',
      category: const FeedCategory(
        id: 'cat-travel',
        name: 'Du lịch',
        icon: 'flight',
        color: '#06B6D4',
      ),
      amount: -2400000,
      currency: 'VND',
      isAmountHidden: false,
      note: 'Book vé Đà Lạt cuối tuần xong rồi! Ai đi cùng không nào? ✈️🌲',
      photoUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
      locationName: 'Đà Lạt Trip',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      reactionsCount: 19,
      topReactions: const [ReactionEmoji.love, ReactionEmoji.wow],
      myReaction: null,
    ),
    FeedPost(
      id: 'tx-mock-4',
      author: const FeedAuthor(
        id: 'u-anh-thu',
        fullName: 'Anh Thư',
        username: 'anhthu',
        avatar: null,
      ),
      name: 'Cold Brew cam sả',
      category: const FeedCategory(
        id: 'cat-coffee',
        name: 'Cà phê',
        icon: 'coffee',
        color: '#EC4899',
      ),
      amount: -115000,
      currency: 'VND',
      isAmountHidden: false,
      note: 'Cold Brew cam sả chiều thứ 7 chill chill cùng hội bạn thân ☕✨',
      photoUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&auto=format&fit=crop&q=80',
      locationName: 'Starbucks Reserve',
      transactionDate: DateTime.now().subtract(const Duration(hours: 3)),
      reactionsCount: 24,
      topReactions: const [ReactionEmoji.love, ReactionEmoji.clap],
      myReaction: ReactionEmoji.love,
    ),
    FeedPost(
      id: 'tx-mock-5',
      author: const FeedAuthor(
        id: 'u-minh-tuan',
        fullName: 'Minh Tuấn',
        username: 'minhtuan',
        avatar: null,
      ),
      name: 'Gia hạn gói Gym',
      category: const FeedCategory(
        id: 'cat-fitness',
        name: 'Thể thao',
        icon: 'fitness',
        color: '#8B5CF6',
      ),
      amount: -650000,
      currency: 'VND',
      isAmountHidden: false,
      note: 'Gia hạn gói tập gym 3 tháng, kỷ luật chi tiêu cho sức khỏe! 💪🏋️',
      photoUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&auto=format&fit=crop&q=80',
      locationName: 'Fitness & Yoga',
      transactionDate: DateTime.now().subtract(const Duration(hours: 5)),
      reactionsCount: 18,
      topReactions: const [ReactionEmoji.clap, ReactionEmoji.like],
      myReaction: null,
    ),
  ];

  @override
  Future<List<FeedPost>> getFeed({FeedQuery query = const FeedQuery()}) async {
    try {
      final dtos = await _api.getFeed(query.toQueryParams());
      final items = dtos.map(mapper.toDomainPost).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback khi không có kết nối hoặc backend rỗng
    }
    return _inMemoryFallback;
  }

  @override
  Future<ReactionEmoji> addReaction({
    required String transactionId,
    required ReactionEmoji emoji,
  }) async {
    try {
      final res = await _api.addReaction(transactionId, emoji.value);
      final resolved = ReactionEmoji.fromString(res.emoji) ?? emoji;
      _updateFallbackReaction(transactionId, resolved);
      return resolved;
    } catch (_) {
      _updateFallbackReaction(transactionId, emoji);
      return emoji;
    }
  }

  @override
  Future<void> removeReaction(String transactionId) async {
    try {
      await _api.removeReaction(transactionId);
    } catch (_) {
      // Ignore network errors
    } finally {
      _removeFallbackReaction(transactionId);
    }
  }

  @override
  Future<List<PostReaction>> getReactions(String transactionId) async {
    try {
      final dtos = await _api.getReactions(transactionId);
      final items = dtos.map(mapper.toDomainReaction).toList();
      if (items.isNotEmpty) return items;
    } catch (_) {
      // Fallback
    }

    // Default mock reactions
    return [
      PostReaction(
        userId: 'u-minh',
        fullName: 'Hoàng Văn Minh',
        emoji: ReactionEmoji.love,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      PostReaction(
        userId: 'u-nam',
        fullName: 'Nguyễn Hải Nam',
        emoji: ReactionEmoji.like,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostReaction(
        userId: 'u-vy',
        fullName: 'Trần Thảo Vy',
        emoji: ReactionEmoji.clap,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Future<FeedPost> updatePost({
    required String transactionId,
    String? visibility,
    bool? amountHidden,
    String? note,
  }) async {
    try {
      final req = UpdateFeedPostRequestDto(
        visibility: visibility,
        amountHidden: amountHidden,
        note: note,
      );
      await _api.updatePost(transactionId, req.toJson());
    } catch (_) {
      // Bỏ qua lỗi mạng
    }

    final index = _inMemoryFallback.indexWhere((p) => p.id == transactionId);
    if (index != -1) {
      final existing = _inMemoryFallback[index];
      final updated = existing.copyWith(
        isAmountHidden: amountHidden ?? existing.isAmountHidden,
        note: note ?? existing.note,
      );
      _inMemoryFallback[index] = updated;
      return updated;
    }

    return FeedPost(
      id: transactionId,
      author: const FeedAuthor(id: 'me', fullName: 'Tôi', username: 'me'),
      name: 'Giao dịch',
      isAmountHidden: amountHidden ?? false,
      note: note,
      transactionDate: DateTime.now(),
    );
  }

  void _updateFallbackReaction(String transactionId, ReactionEmoji emoji) {
    final idx = _inMemoryFallback.indexWhere((p) => p.id == transactionId);
    if (idx != -1) {
      final old = _inMemoryFallback[idx];
      final wasReacted = old.myReaction != null;
      final newCount = wasReacted ? old.reactionsCount : old.reactionsCount + 1;
      _inMemoryFallback[idx] = old.copyWith(
        reactionsCount: newCount,
        myReaction: emoji,
      );
    }
  }

  void _removeFallbackReaction(String transactionId) {
    final idx = _inMemoryFallback.indexWhere((p) => p.id == transactionId);
    if (idx != -1) {
      final old = _inMemoryFallback[idx];
      final newCount = old.reactionsCount > 0 ? old.reactionsCount - 1 : 0;
      _inMemoryFallback[idx] = old.copyWith(
        reactionsCount: newCount,
        clearMyReaction: true,
      );
    }
  }
}

