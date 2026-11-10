class MessageValidators {
  MessageValidators._();

  static String? validateMessageContent(String? value) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Tin nhắn không được để trống';
    if (t.length > 2000) return 'Tin nhắn tối đa 2000 ký tự';
    return null;
  }
}
