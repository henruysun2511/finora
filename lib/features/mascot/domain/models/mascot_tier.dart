import '../../../../core/widgets/mascot/mascot_registry.dart';

/// Entity đại diện cho một nấc thang tiến hóa linh vật tài chính
class MascotTier {
  const MascotTier({
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
  final String tierName; // ash | penny | sage | nora | jade | ruby | bellingham
  final String displayName; // Từ backend: 'Kẻ Sinh Tồn', 'Huấn Luyện Viên Đời Sống'...
  final double minNetWorth;
  final double? maxNetWorth;
  final int displayOrder;
  final List<String> quotes;
  final String systemPrompt;
  final String htmlContent;
  final String? mascotAssetUrl;
  final bool isActive;

  /// Tên gọi chuẩn của linh vật (Ash, Penny, Sage, Nora, Jade, Ruby, Bellingham)
  String get name {
    final reg = MascotRegistry.get(tierName);
    return reg.name;
  }

  /// Danh xưng / vai trò linh vật (Kẻ Sinh Tồn, Huấn Luyện Viên Đời Sống...)
  String get roleName {
    // Nếu displayName chứa vai trò khác với tên (e.g. 'Kẻ Sinh Tồn') thì ưu tiên dùng
    if (displayName.isNotEmpty &&
        displayName.toLowerCase() != name.toLowerCase() &&
        displayName.toLowerCase() != tierName.toLowerCase()) {
      return displayName;
    }
    final reg = MascotRegistry.get(tierName);
    return reg.role;
  }

  /// Tiêu đề đầy đủ chuẩn không trùng lặp: "Ash · Kẻ Sinh Tồn"
  String get fullTitle => '$name · $roleName';

  /// Chuỗi hiển thị khoảng tài sản ròng chuẩn
  String get rangeLabel {
    final cleanKey = tierName.trim().toLowerCase();

    if (minNetWorth < 0 || cleanKey == 'ash') {
      return 'Nợ nần (< 0 ₫)';
    }

    if (cleanKey == 'penny') {
      return '0 ₫ – 1 triệu ₫';
    }

    final minM = (minNetWorth / 1000000).toStringAsFixed(minNetWorth % 1000000 == 0 ? 0 : 1);

    if (maxNetWorth == null || maxNetWorth! > 5000000000 || cleanKey == 'bellingham') {
      return '> $minM triệu ₫';
    }

    final maxM = (maxNetWorth! / 1000000).toStringAsFixed(maxNetWorth! % 1000000 == 0 ? 0 : 1);
    return '$minM – $maxM triệu ₫';
  }
}
