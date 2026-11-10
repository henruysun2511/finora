enum ReactionEmoji {
  like('like', '👍', 'Thích'),
  love('love', '❤️', 'Yêu thích'),
  haha('haha', '😆', 'Haha'),
  laugh('laugh', '😂', 'Cười'),
  wow('wow', '😮', 'Bất ngờ'),
  sad('sad', '😢', 'Buồn'),
  clap('clap', '👏', 'Vỗ tay'),
  angry('angry', '😡', 'Phẫn nộ');

  const ReactionEmoji(this.value, this.symbol, this.label);

  final String value;
  final String symbol;
  final String label;

  static ReactionEmoji? fromString(String? val) {
    if (val == null) return null;
    final normalized = val.trim().toLowerCase();
    for (final e in ReactionEmoji.values) {
      if (e.value == normalized) return e;
    }
    return null;
  }
}

