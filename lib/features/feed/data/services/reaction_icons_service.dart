import 'package:dio/dio.dart';
import '../../domain/models/reaction_emoji.dart';
import '../../domain/models/reaction_icon_item.dart';

class ReactionIconsService {
  final Dio _dio;

  ReactionIconsService([Dio? dio]) : _dio = dio ?? Dio();

  /// Endpoint API ngoài để lấy danh sách icon/emoji
  static const String externalEmojiApiUrl =
      'https://emojihub.yurace.pro/api/all/category/smileys-and-people';

  /// Danh sách icon cảm xúc FinTech & Social chuẩn bị sẵn (Fallback & Core)
  static const List<ReactionIconItem> defaultIcons = [
    ReactionIconItem(
      id: 'love_fire',
      symbol: '🔥',
      label: 'Yêu thích',
      category: 'Phổ biến',
      emoji: ReactionEmoji.love,
      lucideIcon: 'flame',
    ),
    ReactionIconItem(
      id: 'love_heart',
      symbol: '❤️',
      label: 'Thả tim',
      category: 'Phổ biến',
      emoji: ReactionEmoji.love,
      lucideIcon: 'heart',
    ),
    ReactionIconItem(
      id: 'like',
      symbol: '👍',
      label: 'Thích',
      category: 'Phổ biến',
      emoji: ReactionEmoji.like,
    ),
    ReactionIconItem(
      id: 'clap',
      symbol: '👏',
      label: 'Vỗ tay',
      category: 'Phổ biến',
      emoji: ReactionEmoji.clap,
    ),
    ReactionIconItem(
      id: 'haha',
      symbol: '😆',
      label: 'Haha',
      category: 'Cảm xúc',
      emoji: ReactionEmoji.haha,
    ),
    ReactionIconItem(
      id: 'laugh',
      symbol: '😂',
      label: 'Cười tươi',
      category: 'Cảm xúc',
      emoji: ReactionEmoji.laugh,
    ),
    ReactionIconItem(
      id: 'wow',
      symbol: '😮',
      label: 'Bất ngờ',
      category: 'Cảm xúc',
      emoji: ReactionEmoji.wow,
    ),
    ReactionIconItem(
      id: 'sad',
      symbol: '😢',
      label: 'Buồn',
      category: 'Cảm xúc',
      emoji: ReactionEmoji.sad,
    ),
    ReactionIconItem(
      id: 'angry',
      symbol: '😡',
      label: 'Phẫn nộ',
      category: 'Cảm xúc',
      emoji: ReactionEmoji.angry,
    ),
    ReactionIconItem(
      id: 'money_wings',
      symbol: '💸',
      label: 'Tiền tài',
      category: 'Tài chính',
      emoji: ReactionEmoji.love,
    ),
    ReactionIconItem(
      id: 'money_bag',
      symbol: '💰',
      label: 'Giàu có',
      category: 'Tài chính',
      emoji: ReactionEmoji.love,
    ),
    ReactionIconItem(
      id: 'rocket',
      symbol: '🚀',
      label: 'Đột phá',
      category: 'Tài chính',
      emoji: ReactionEmoji.like,
    ),
    ReactionIconItem(
      id: 'coffee',
      symbol: '☕',
      label: 'Cà phê',
      category: 'Đời sống',
      emoji: ReactionEmoji.like,
    ),
    ReactionIconItem(
      id: 'party',
      symbol: '🎉',
      label: 'Chúc mừng',
      category: 'Đời sống',
      emoji: ReactionEmoji.clap,
    ),
    ReactionIconItem(
      id: 'muscle',
      symbol: '💪',
      label: 'Cố lên',
      category: 'Đời sống',
      emoji: ReactionEmoji.clap,
    ),
    ReactionIconItem(
      id: 'sparkles',
      symbol: '✨',
      label: 'Tuyệt hảo',
      category: 'Phổ biến',
      emoji: ReactionEmoji.love,
    ),
    ReactionIconItem(
      id: 'star',
      symbol: '⭐',
      label: 'Xuất sắc',
      category: 'Phổ biến',
      emoji: ReactionEmoji.like,
    ),
    ReactionIconItem(
      id: 'crown',
      symbol: '👑',
      label: 'Đỉnh chóp',
      category: 'Đời sống',
      emoji: ReactionEmoji.love,
    ),
  ];

  /// Gọi API ngoài để lấy danh sách icon, nếu lỗi hoặc chậm sẽ trả về bộ icon chuẩn
  Future<List<ReactionIconItem>> fetchReactionIcons() async {
    try {
      final response = await _dio
          .get<dynamic>(
            externalEmojiApiUrl,
            options: Options(
              sendTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 4),
            ),
          );

      if (response.statusCode == 200 && response.data is List) {
        final List list = response.data as List;
        final externalItems = <ReactionIconItem>[];

        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final name = item['name'] as String? ?? '';
            final unicodeList = item['unicode'] as List?;
            String symbol = '';

            if (unicodeList != null && unicodeList.isNotEmpty) {
              final codes = <int>[];
              for (final u in unicodeList) {
                final raw = u
                    .toString()
                    .replaceAll('U+', '')
                    .replaceAll('u+', '')
                    .trim();
                final code = int.tryParse(raw, radix: 16);
                if (code != null && code > 0) {
                  codes.add(code);
                }
              }
              if (codes.isNotEmpty) {
                try {
                  symbol = String.fromCharCodes(codes);
                } catch (_) {
                  symbol = '';
                }
              }
            }

            if (symbol.isNotEmpty) {
              externalItems.add(
                ReactionIconItem(
                  id: name.toLowerCase().replaceAll(' ', '_'),
                  symbol: symbol,
                  label: _formatEmojiName(name),
                  category: 'Mở rộng',
                  emoji: _mapNameToEmoji(name),
                ),
              );
            }
          }
          if (externalItems.length >= 15) break; // Lấy thêm các icon tiêu biểu
        }

        if (externalItems.isNotEmpty) {
          return [...defaultIcons, ...externalItems];
        }
      }
    } catch (_) {
      // Khi không có kết nối internet hoặc API ngoài timeout, fallback sang defaultIcons
    }

    return defaultIcons;
  }

  String _formatEmojiName(String raw) {
    if (raw.isEmpty) return 'Biểu tượng';
    final words = raw.split(' ');
    if (words.length <= 2) return raw;
    return words.take(2).join(' ');
  }

  ReactionEmoji _mapNameToEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('heart') || lower.contains('love') || lower.contains('kiss')) {
      return ReactionEmoji.love;
    }
    if (lower.contains('laugh') || lower.contains('grin')) {
      return ReactionEmoji.laugh;
    }
    if (lower.contains('smile') || lower.contains('joy')) {
      return ReactionEmoji.haha;
    }
    if (lower.contains('sad') || lower.contains('cry') || lower.contains('tear')) {
      return ReactionEmoji.sad;
    }
    if (lower.contains('angry') || lower.contains('rage') || lower.contains('frown')) {
      return ReactionEmoji.angry;
    }
    if (lower.contains('surprise') || lower.contains('shock') || lower.contains('open mouth')) {
      return ReactionEmoji.wow;
    }
    return ReactionEmoji.like;
  }
}

