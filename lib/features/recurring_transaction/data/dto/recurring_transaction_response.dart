/// DTO khớp với RecurringTransactionResponseDto của backend
class RecurringTransactionResponse {
  RecurringTransactionResponse({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.currency,
    required this.isPaused,
    required this.nextRunDate,
    required this.createdAt,
    this.accountName,
    this.category,
    this.endDate,
    // Detail fields - chỉ có khi gọi GET /:id
    this.totalExecutedTimes,
    this.totalAmountSpent,
    this.executionHistory,
  });

  final String id;
  final String name;
  final num amount;
  final String type;
  final String frequency;
  final String currency;
  final bool isPaused;
  final String nextRunDate; // ISO date string
  final String createdAt; // ISO date string
  final String? accountName;
  final CategoryBriefResponse? category;
  final String? endDate; // ISO date string, nullable
  final int? totalExecutedTimes;
  final num? totalAmountSpent;
  final List<ExecutionHistoryItemResponse>? executionHistory;

  factory RecurringTransactionResponse.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? 'EXPENSE',
      frequency: json['frequency'] ?? 'MONTHLY',
      currency: json['currency'] ?? 'VND',
      isPaused: json['isPaused'] ?? false,
      nextRunDate: json['nextRunDate']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      accountName: json['accountName'],
      category: json['category'] != null
          ? CategoryBriefResponse.fromJson(json['category'])
          : null,
      endDate: json['endDate']?.toString(),
      totalExecutedTimes: json['totalExecutedTimes'],
      totalAmountSpent: json['totalAmountSpent'],
      executionHistory: json['executionHistory'] != null
          ? (json['executionHistory'] as List)
              .map((e) => ExecutionHistoryItemResponse.fromJson(e))
              .toList()
          : null,
    );
  }
}

/// DTO cho category brief - khớp với CategoryBriefResponseDto
class CategoryBriefResponse {
  const CategoryBriefResponse({
    required this.id,
    required this.name,
    this.icon,
  });

  final String id;
  final String name;
  final String? icon;

  factory CategoryBriefResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBriefResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

/// DTO lịch sử thực thi - khớp với ExecutionHistoryItemDto
class ExecutionHistoryItemResponse {
  const ExecutionHistoryItemResponse({
    required this.transactionId,
    required this.amount,
    required this.date,
  });

  final String transactionId;
  final num amount;
  final String date; // ISO date string

  factory ExecutionHistoryItemResponse.fromJson(Map<String, dynamic> json) {
    return ExecutionHistoryItemResponse(
      transactionId: json['transactionId'] ?? '',
      amount: json['amount'] ?? 0,
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}