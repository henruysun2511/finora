import '../../domain/models/feed_author.dart';
import '../../domain/models/feed_category.dart';
import '../../domain/models/feed_post.dart';
import '../../domain/models/post_reaction.dart';
import '../../domain/models/reaction_emoji.dart';
import '../dto/feed_post_response.dart';
import '../dto/post_reaction_response.dart';

class FeedMapper {
  const FeedMapper();

  FeedPost toDomainPost(FeedPostResponseDto dto) {
    return FeedPost(
      id: dto.id,
      author: FeedAuthor(
        id: dto.author.id,
        fullName: dto.author.fullName,
        username: dto.author.username,
        avatar: dto.author.avatar,
      ),
      name: dto.name,
      category: dto.category != null
          ? FeedCategory(
              id: dto.category!.id,
              name: dto.category!.name,
              icon: dto.category!.icon,
              color: dto.category!.color,
            )
          : null,
      amount: dto.amount,
      currency: dto.currency,
      isAmountHidden: dto.isAmountHidden,
      note: dto.note,
      photoUrl: dto.photoUrl,
      photoType: dto.photoType,
      locationName: dto.locationName,
      transactionDate: dto.transactionDate,
      reactionsCount: dto.reactionsCount,
      topReactions: dto.topReactions
          .map(ReactionEmoji.fromString)
          .whereType<ReactionEmoji>()
          .toList(),
      myReaction: ReactionEmoji.fromString(dto.myReaction),
    );
  }

  PostReaction toDomainReaction(PostReactionResponseDto dto) {
    return PostReaction(
      userId: dto.userId,
      fullName: dto.fullName,
      avatar: dto.avatar,
      emoji: ReactionEmoji.fromString(dto.emoji) ?? ReactionEmoji.like,
      createdAt: dto.createdAt,
    );
  }
}

