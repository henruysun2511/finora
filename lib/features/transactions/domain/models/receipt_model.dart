class ReceiptItemModel {
  final String name;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const ReceiptItemModel({
    required this.name,
    this.quantity = 1,
    this.unitPrice = 0,
    required this.totalPrice,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toDouble() ?? 1.0;
    final total = (json['total_price'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;
    final unit = (json['unit_price'] as num?)?.toDouble() ??
        (qty > 0 && total > 0 ? (total / qty) : 0.0);

    return ReceiptItemModel(
      name: json['name'] as String? ??
          json['item_name'] as String? ??
          json['description'] as String? ??
          'Mặt hàng',
      quantity: qty,
      unitPrice: unit,
      totalPrice: total > 0 ? total : (qty * unit),
    );
  }
}

class ReceiptModel {
  final String id;
  final String? imageUrl;
  final String? merchantName;
  final String? merchantAddress;
  final double totalAmount;
  final double? taxAmount;
  final double? tipAmount;
  final List<ReceiptItemModel> items;
  final DateTime? scannedAt;

  const ReceiptModel({
    required this.id,
    this.imageUrl,
    this.merchantName,
    this.merchantAddress,
    required this.totalAmount,
    this.taxAmount,
    this.tipAmount,
    this.items = const [],
    this.scannedAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    List<ReceiptItemModel> parsedItems = [];

    // Parse items from ocrRawData or direct items list
    dynamic rawItems;
    if (json['ocrRawData'] is Map<String, dynamic>) {
      final ocr = json['ocrRawData'] as Map<String, dynamic>;
      rawItems = ocr['items'] ?? ocr['line_items'];
    }
    rawItems ??= json['items'];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(ReceiptItemModel.fromJson(item));
        }
      }
    }

    String? merchant = json['merchantName'] as String?;
    String? address;
    if (json['ocrRawData'] is Map<String, dynamic>) {
      final ocr = json['ocrRawData'] as Map<String, dynamic>;
      merchant ??= ocr['merchant_name'] as String?;
      address = ocr['merchant_address'] as String?;
    }

    final total = (json['totalAmount'] as num?)?.toDouble() ??
        (json['total_amount'] as num?)?.toDouble() ??
        0.0;
    final tax = (json['taxAmount'] as num?)?.toDouble() ??
        (json['tax'] as num?)?.toDouble();
    final tip = (json['tipAmount'] as num?)?.toDouble() ??
        (json['tip'] as num?)?.toDouble();

    return ReceiptModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['photoUrl'] as String?,
      merchantName: merchant,
      merchantAddress: address,
      totalAmount: total,
      taxAmount: tax,
      tipAmount: tip,
      items: parsedItems,
      scannedAt: json['scannedAt'] != null
          ? DateTime.tryParse(json['scannedAt'].toString())
          : null,
    );
  }
}
