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

  @override
  Future<List<FeedPost>> getFeed({FeedQuery query = const FeedQuery()}) async {
    try {
      final dtos = await _api.getFeed(query.toQueryParams());
      return dtos.map(mapper.toDomainPost).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ReactionEmoji> addReaction({
    required String transactionId,
    required ReactionEmoji emoji,
  }) async {
    final res = await _api.addReaction(transactionId, emoji.value);
    return ReactionEmoji.fromString(res.emoji) ?? emoji;
  }

  @override
  Future<void> removeReaction(String transactionId) async {
    await _api.removeReaction(transactionId);
  }

  @override
  Future<List<PostReaction>> getReactions(String transactionId) async {
    try {
      final list = await _api.getReactions(transactionId);
      return list.map(mapper.toDomainReaction).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<FeedPost> updatePost({
    required String transactionId,
    String? visibility,
    bool? amountHidden,
    String? note,
  }) async {
    final req = UpdateFeedPostRequestDto(
      visibility: visibility,
      amountHidden: amountHidden,
      note: note,
    );
    final res = await _api.updatePost(transactionId, req.toJson());
    return mapper.toDomainPost(res);
  }
}
