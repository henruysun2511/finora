import 'package:flutter/material.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/product.dart';

/// Hộp thoại xác nhận xóa sản phẩm (sử dụng ConfirmDialog dùng chung)
Future<bool> confirmDeleteProduct(BuildContext context, Product product) {
  return showConfirmDialog(
    context,
    title: 'Xác nhận xóa sản phẩm',
    message:
        'Bạn có chắc muốn xóa vĩnh viễn "${product.name}" khỏi hệ thống? Hành động này không thể hoàn tác.',
    confirmText: 'Xóa ngay',
    isDestructive: true,
  );
}
