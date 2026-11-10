import '../models/feed_post.dart';
import '../models/feed_query.dart';
import '../models/post_reaction.dart';
import '../models/reaction_emoji.dart';

abstract class FeedRepository {
  /// 1. Lấy danh sách bài đăng Bảng tin (có phân trang, có thể lọc theo friendId)
  Future<List<FeedPost>> getFeed({FeedQuery query = const FeedQuery()});

  /// 2. Thả hoặc đổi reaction
  Future<ReactionEmoji> addReaction({
    required String transactionId,
    required ReactionEmoji emoji,
  });

  /// 3. Gỡ bỏ reaction
  Future<void> removeReaction(String transactionId);

  /// 4. Danh sách người đã thả reaction vào bài đăng
  Future<List<PostReaction>> getReactions(String transactionId);

  /// 5. Cập nhật bài đăng (ẩn/hiện số tiền, cập nhật note/caption, chia sẻ hoặc gỡ khỏi bảng tin)
  Future<FeedPost> updatePost({
    required String transactionId,
    String? visibility,
    bool? amountHidden,
    String? note,
  });
}

