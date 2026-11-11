/// Loại tin nhắn trong hệ thống P2P Chat của FINORA:
/// - text: Tin nhắn văn bản thông thường
/// - image: Hình ảnh hoá đơn / khoảnh khắc Locket
/// - transactionShare: Tin nhắn chia sẻ giao dịch thu/chi
/// - moneyRequest: Tin nhắn yêu cầu chuyển khoản / chia tiền
enum MessageType {
  text('TEXT', 'Văn bản'),
  image('IMAGE', 'Hình ảnh'),
  transactionShare('TRANSACTION_SHARE', 'Chia sẻ giao dịch'),
  moneyRequest('MONEY_REQUEST', 'Yêu cầu chuyển tiền');

  const MessageType(this.value, this.label);

  final String value;
  final String label;

  static MessageType fromValue(String? value) {
    return MessageType.values.firstWhere(
      (e) => e.value.toUpperCase() == (value ?? '').toUpperCase(),
      orElse: () => MessageType.text,
    );
  }
}

/// Trạng thái tin nhắn
enum MessageDeliveryStatus {
  sending('SENDING', 'Đang gửi'),
  sent('SENT', 'Đã gửi'),
  delivered('DELIVERED', 'Đã nhận'),
  read('READ', 'Đã xem'),
  failed('FAILED', 'Thất bại');

  const MessageDeliveryStatus(this.value, this.label);

  final String value;
  final String label;

  static MessageDeliveryStatus fromValue(String? value) {
    return MessageDeliveryStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == (value ?? '').toUpperCase(),
      orElse: () => MessageDeliveryStatus.sent,
    );
  }
}

