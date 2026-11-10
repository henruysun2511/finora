class FeedAuthorDto {
  final String id;
  final String fullName;
  final String username;
  final String? avatar;

  const FeedAuthorDto({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatar,
  });

  factory FeedAuthorDto.fromJson(Map<String, dynamic> json) {
    return FeedAuthorDto(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'username': username,
    'avatar': avatar,
  };
}

class FeedCategoryDto {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  const FeedCategoryDto({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory FeedCategoryDto.fromJson(Map<String, dynamic> json) {
    return FeedCategoryDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
  };
}

class FeedPostResponseDto {
  final String id;
  final FeedAuthorDto author;
  final String name;
  final FeedCategoryDto? category;
  final double? amount;
  final String currency;
  final bool isAmountHidden;
  final String? note;
  final String? photoUrl;
  final String? photoType;
  final String? locationName;
  final DateTime transactionDate;
  final int reactionsCount;
  final List<String> topReactions;
  final String? myReaction;

  const FeedPostResponseDto({
    required this.id,
    required this.author,
    required this.name,
    this.category,
    this.amount,
    required this.currency,
    required this.isAmountHidden,
    this.note,
    this.photoUrl,
    this.photoType,
    this.locationName,
    required this.transactionDate,
    required this.reactionsCount,
    required this.topReactions,
    this.myReaction,
  });

  factory FeedPostResponseDto.fromJson(Map<String, dynamic> json) {
    return FeedPostResponseDto(
      id: json['id'] as String? ?? '',
      author: json['author'] != null
          ? FeedAuthorDto.fromJson(json['author'] as Map<String, dynamic>)
          : const FeedAuthorDto(id: '', fullName: '', username: ''),
      name: json['name'] as String? ?? '',
      category: json['category'] != null
          ? FeedCategoryDto.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currency: json['currency'] as String? ?? 'VND',
      isAmountHidden: json['isAmountHidden'] as bool? ?? false,
      note: json['note'] as String?,
      photoUrl: json['photoUrl'] as String?,
      photoType: json['photoType'] as String?,
      locationName: json['locationName'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.tryParse(json['transactionDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reactionsCount: json['reactionsCount'] as int? ?? 0,
      topReactions: (json['topReactions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      myReaction: json['myReaction'] as String?,
    );
  }
}

