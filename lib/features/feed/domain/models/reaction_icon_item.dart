import 'reaction_emoji.dart';

class ReactionIconItem {
  final String id;
  final String symbol;
  final String label;
  final String category;
  final ReactionEmoji emoji;
  final String? lucideIcon;

  const ReactionIconItem({
    required this.id,
    required this.symbol,
    required this.label,
    required this.category,
    required this.emoji,
    this.lucideIcon,
  });

  factory ReactionIconItem.fromJson(Map<String, dynamic> json) {
    final emojiVal = ReactionEmoji.fromString(json['emoji'] as String?) ??
        ReactionEmoji.fromString(json['code'] as String?) ??
        ReactionEmoji.love;

    return ReactionIconItem(
      id: json['id'] as String? ?? json['name'] as String? ?? 'reaction',
      symbol: json['symbol'] as String? ?? json['unicode'] as String? ?? emojiVal.symbol,
      label: json['label'] as String? ?? json['name'] as String? ?? emojiVal.label,
      category: json['category'] as String? ?? 'Phổ biến',
      emoji: emojiVal,
      lucideIcon: json['lucideIcon'] as String?,
    );
  }
}

