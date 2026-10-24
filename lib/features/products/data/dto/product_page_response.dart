import 'product_response.dart';

/// DTO phân trang hỗ trợ chuẩn ApiResponse của finora_be:
/// `{ "data": { "items": [...], "pagination": { "page": 1, "limit": 10, "total": 57, "totalPages": 6 } } }`
class ProductPageResponse {
  const ProductPageResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<ProductResponse> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory ProductPageResponse.fromJson(Map<String, dynamic> json) {
    // 1. Trích xuất phần thân (hỗ trợ cả khi có vỏ bọc ApiResponse của finora_be)
    Map<String, dynamic> payload = json;
    if (json['data'] is Map<String, dynamic>) {
      payload = json['data'] as Map<String, dynamic>;
    }

    // 2. Trích xuất danh sách sản phẩm (hỗ trợ 'items' của finora_be hoặc 'data')
    final rawList = payload['items'] ?? payload['data'] ?? (json['data'] is List ? json['data'] : []);
    final items = (rawList as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => ProductResponse.fromJson(e))
        .toList();

    // 3. Trích xuất phân trang (hỗ trợ 'pagination' của finora_be hoặc 'meta')
    final pagination = (payload['pagination'] is Map<String, dynamic>)
        ? payload['pagination'] as Map<String, dynamic>
        : (payload['meta'] is Map<String, dynamic>)
            ? payload['meta'] as Map<String, dynamic>
            : <String, dynamic>{};

    final page = (pagination['page'] as num?)?.toInt() ?? 1;
    final limit = (pagination['limit'] as num?)?.toInt() ?? (items.isNotEmpty ? items.length : 10);
    final total = (pagination['total'] as num?)?.toInt() ?? items.length;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ??
        (total > 0 && limit > 0 ? (total / limit).ceil() : 1);

    return ProductPageResponse(
      data: items,
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
    );
  }
}
