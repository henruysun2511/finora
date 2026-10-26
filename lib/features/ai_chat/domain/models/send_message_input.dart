class SendMessageInput {
  final String walletId;
  final String message;
  final String source;
  final String? intentOverride;

  const SendMessageInput({
    required this.walletId,
    required this.message,
    this.source = 'CHAT_TEXT',
    this.intentOverride,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'walletId': walletId,
      'message': message,
      'source': source,
    };
    if (intentOverride != null && intentOverride!.isNotEmpty) {
      map['intentOverride'] = intentOverride;
    }
    return map;
  }
}

enum PendingActionDecision {
  confirm,
  reject;

  String toApiString() => this == PendingActionDecision.confirm ? 'CONFIRM' : 'REJECT';
}

class EditTransactionDraft {
  final String? type; // EXPENSE | INCOME
  final String? name;
  final double? amount;
  final String? accountId;
  final String? categoryId;
  final String? categoryName;
  final String? accountName;
  final String? date;
  final String? note;
  final String? locationName;
  final String? visibility; // PRIVATE | FRIENDS
  final bool? amountHidden;
  final bool? excludeFromReport;
  final String? photoUrl;

  const EditTransactionDraft({
    this.type,
    this.name,
    this.amount,
    this.accountId,
    this.categoryId,
    this.categoryName,
    this.accountName,
    this.date,
    this.note,
    this.locationName,
    this.visibility,
    this.amountHidden,
    this.excludeFromReport,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (type != null) map['type'] = type;
    if (name != null) map['name'] = name;
    if (amount != null) map['amount'] = amount;
    if (accountId != null) map['accountId'] = accountId;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (date != null) map['date'] = date;
    if (note != null) map['note'] = note;
    if (locationName != null) map['locationName'] = locationName;
    if (visibility != null) map['visibility'] = visibility;
    if (amountHidden != null) map['amountHidden'] = amountHidden;
    if (excludeFromReport != null) map['excludeFromReport'] = excludeFromReport;
    if (photoUrl != null) map['photoUrl'] = photoUrl;
    return map;
  }

  factory EditTransactionDraft.fromJson(Map<String, dynamic> json) {
    return EditTransactionDraft(
      type: json['type'] as String?,
      name: json['name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      accountId: json['accountId'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      accountName: json['accountName'] as String?,
      date: json['date'] as String?,
      note: json['note'] as String?,
      locationName: json['locationName'] as String?,
      visibility: json['visibility'] as String?,
      amountHidden: json['amountHidden'] as bool?,
      excludeFromReport: json['excludeFromReport'] as bool?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
