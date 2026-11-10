/// Pure functions kiểm tra dữ liệu đầu vào cho Tin nhắn.
/// Tách rời hoàn toàn khỏi Flutter UI để viết Unit Test thuận lợi.
class MessageValidators {
  MessageValidators._();

  /// Kiểm tra nội dung tin nhắn gửi đi
  static String? validateContent(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Nội dung tin nhắn không được để trống';
    if (t.length > 2000) return 'Tin nhắn tối đa 2000 ký tự';
    return null;
  }

  /// Kiểm tra người nhận (receiverId)
  static String? validateReceiverId(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Vui lòng chỉ định người nhận tin nhắn';
    return null;
  }
}

