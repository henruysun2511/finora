/// Các hàm xác thực thuần cho Danh mục (Pure Domain Validators).
/// Không phụ thuộc Flutter Framework hay UI context.
class CategoryValidators {
  CategoryValidators._();

  /// Tên danh mục không được để trống và độ dài từ 2 đến 50 ký tự.
  static String? validateName(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) {
      return 'Tên danh mục không được để trống';
    }
    if (v.length < 2) {
      return 'Tên danh mục phải có ít nhất 2 ký tự';
    }
    if (v.length > 50) {
      return 'Tên danh mục không được vượt quá 50 ký tự';
    }
    return null;
  }

  /// Mã màu HEX hợp lệ (ví dụ #1E5BD8 hoặc #FF5733).
  static String? validateColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^#?([0-9a-fA-F]{6})$');
    if (!regex.hasMatch(value.trim())) {
      return 'Mã màu không hợp lệ (ví dụ: #1E5BD8)';
    }
    return null;
  }
}

