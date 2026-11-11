import 'feed_author.dart';
import 'feed_category.dart';
import 'reaction_emoji.dart';

class FeedPost {
  const FeedPost({
    required this.id,
    required this.author,
    required this.name,
    this.category,
    this.amount,
    this.currency = 'VND',
    this.isAmountHidden = false,
    this.note,
    this.photoUrl,
    this.photoType,
    this.locationName,
    required this.transactionDate,
    this.reactionsCount = 0,
    this.topReactions = const [],
    this.myReaction,
    this.myReactionSymbol,
    this.myReactionLabel,
  });

  final String id;
  final FeedAuthor author;
  final String name;
  final FeedCategory? category;
  final double? amount;
  final String currency;
  final bool isAmountHidden;
  final String? note;
  final String? photoUrl;
  final String? photoType;
  final String? locationName;
  final DateTime transactionDate;
  final int reactionsCount;
  final List<ReactionEmoji> topReactions;
  final ReactionEmoji? myReaction;
  final String? myReactionSymbol;
  final String? myReactionLabel;

  bool get hasReacted => myReaction != null || myReactionSymbol != null;

  FeedPost copyWith({
    String? id,
    FeedAuthor? author,
    String? name,
    FeedCategory? category,
    double? amount,
    String? currency,
    bool? isAmountHidden,
    String? note,
    String? photoUrl,
    String? photoType,
    String? locationName,
    DateTime? transactionDate,
    int? reactionsCount,
    List<ReactionEmoji>? topReactions,
    ReactionEmoji? myReaction,
    String? myReactionSymbol,
    String? myReactionLabel,
    bool clearMyReaction = false,
  }) {
    return FeedPost(
      id: id ?? this.id,
      author: author ?? this.author,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      isAmountHidden: isAmountHidden ?? this.isAmountHidden,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
      photoType: photoType ?? this.photoType,
      locationName: locationName ?? this.locationName,
      transactionDate: transactionDate ?? this.transactionDate,
      reactionsCount: reactionsCount ?? this.reactionsCount,
      topReactions: topReactions ?? this.topReactions,
      myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
      myReactionSymbol:
          clearMyReaction ? null : (myReactionSymbol ?? this.myReactionSymbol),
      myReactionLabel:
          clearMyReaction ? null : (myReactionLabel ?? this.myReactionLabel),
    );
  }
}

