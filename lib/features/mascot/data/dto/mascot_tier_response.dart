import '../../../../core/widgets/mascot/mascot_registry.dart';

/// DTO ánh xạ thông tin linh vật từ backend
class MascotTierResponse {
  const MascotTierResponse({
    required this.id,
    required this.tierName,
    required this.displayName,
    required this.minNetWorth,
    this.maxNetWorth,
    this.displayOrder = 1,
    this.quotes = const [],
    this.systemPrompt = '',
    this.htmlContent = '',
    this.mascotAssetUrl,
    this.isActive = true,
  });

  final String id;
  final String tierName;
  final String displayName;
  final double minNetWorth;
  final double? maxNetWorth;
  final int displayOrder;
  final List<String> quotes;
  final String systemPrompt;
  final String htmlContent;
  final String? mascotAssetUrl;
  final bool isActive;

  factory MascotTierResponse.fromJson(Map<String, dynamic> json) {
    List<String> quoteList = const [];
    if (json['quotes'] is List) {
      quoteList = (json['quotes'] as List).map((e) => e.toString()).toList();
    }

    final key = json['tierName']?.toString().toLowerCase().trim() ?? 'nora';
    final reg = MascotRegistry.get(key);

    // Nếu API chỉ trả về MascotSimpleResponseDto (thiếu minNetWorth), tự động đối chiếu từ MascotRegistry
    final rawMin = (json['minNetWorth'] as num?)?.toDouble();
    final rawMax = (json['maxNetWorth'] as num?)?.toDouble();

    final effectiveMin = rawMin ?? reg.min;
    final effectiveMax = rawMax ?? (reg.max > 5000000000 ? null : reg.max);

    return MascotTierResponse(
      id: json['id']?.toString() ?? key,
      tierName: key,
      displayName: json['displayName']?.toString() ?? reg.name,
      minNetWorth: effectiveMin,
      maxNetWorth: effectiveMax,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 1,
      quotes: quoteList.isNotEmpty ? quoteList : reg.quotes,
      systemPrompt: json['systemPrompt']?.toString() ?? reg.personality,
      htmlContent: json['htmlContent']?.toString() ?? '',
      mascotAssetUrl: json['mascotAssetUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
