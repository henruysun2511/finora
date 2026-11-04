/// Phong cách / Giọng điệu giao tiếp của Linh vật AI
enum MascotTone {
  gentle('GENTLE', 'Dịu dàng', 'Thấu cảm, động viên nhẹ nhàng và khích lệ tích cực.', '🌸'),
  balanced('BALANCED', 'Cân bằng', 'Khách quan, thực tế, phân tích tài chính dựa trên dữ liệu logic.', '⚖️'),
  roast('ROAST', 'Cà khịa', 'Thẳng thắn, hài hước, châm biếm chi tiêu hoang phí để cảnh tỉnh.', '🔥');

  const MascotTone(this.value, this.label, this.description, this.emoji);

  final String value;
  final String label;
  final String description;
  final String emoji;

  static MascotTone fromString(String? val) {
    if (val == null) return MascotTone.balanced;
    return MascotTone.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => MascotTone.balanced,
    );
  }
}

/// Độ nhạy / Tần suất cảnh báo của Linh vật
enum MascotSensitivity {
  all('ALL', 'Tất cả chi tiêu', 'Nhận xét và đưa ra lời khuyên sau mọi giao dịch.'),
  anomaliesOnly('ANOMALIES_ONLY', 'Chỉ khi bất thường', 'Chỉ cảnh báo khi chi vượt hạn mức hoặc có dấu hiệu bất thường.'),
  silent('SILENT', 'Im lặng', 'Không chủ động hiện lời khuyên sau giao dịch.');

  const MascotSensitivity(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static MascotSensitivity fromString(String? val) {
    if (val == null) return MascotSensitivity.anomaliesOnly;
    return MascotSensitivity.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => MascotSensitivity.anomaliesOnly,
    );
  }
}

