import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_input.dart';
import 'product_detail_provider.dart';
import 'product_form_state.dart';
import 'product_list_provider.dart';
import 'product_providers.dart';

/// Tham số family: id sản phẩm khi sửa, null khi tạo mới.
class ProductFormNotifier
    extends AutoDisposeFamilyNotifier<ProductFormState, String?> {
  @override
  ProductFormState build(String? arg) => const ProductFormState();

  /// Trả về sản phẩm đã lưu, hoặc null nếu lỗi (message nằm trong state).
  Future<Product?> submit(ProductInput input) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final repo = ref.read(productRepositoryProvider);
      final id = arg;
      final saved = id == null
          ? await repo.createProduct(input)
          : await repo.updateProduct(id, input);

      // Làm mới danh sách (và chi tiết nếu đang sửa).
      ref.invalidate(productListProvider);
      if (id != null) ref.invalidate(productDetailProvider(id));

      state = state.copyWith(isSubmitting: false);
      return saved;
    } catch (e) {
      final msg = e is AppException ? e.message : e.toString();
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: msg,
      );
      return null;
    }
  }
}

final productFormProvider = NotifierProvider.autoDispose
    .family<ProductFormNotifier, ProductFormState, String?>(
  ProductFormNotifier.new,
);
