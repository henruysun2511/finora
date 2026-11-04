/// Loại danh mục: Chi tiêu (EXPENSE) hoặc Thu nhập (INCOME)
enum CategoryType {
  expense('EXPENSE', 'Chi tiêu'),
  income('INCOME', 'Thu nhập');

  const CategoryType(this.value, this.label);

  final String value;
  final String label;

  static CategoryType fromValue(String? value) {
    final v = (value ?? '').toUpperCase();
    if (v == 'INCOME') return CategoryType.income;
    return CategoryType.expense;
  }
}

