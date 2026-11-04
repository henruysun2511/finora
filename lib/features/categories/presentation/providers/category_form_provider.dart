import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/category.dart';
import '../../domain/models/category_input.dart';
import 'category_list_provider.dart';
import 'category_providers.dart';

final categoryFormProvider =
    StateNotifierProvider.autoDispose<CategoryFormNotifier, AsyncValue<void>>(
  (ref) => CategoryFormNotifier(ref),
);

class CategoryFormNotifier extends StateNotifier<AsyncValue<void>> {
  CategoryFormNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<Category?> submit({
    String? categoryId,
    required CategoryInput input,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = _ref.read(categoryRepositoryProvider);
      Category result;
      if (categoryId != null && categoryId.isNotEmpty) {
        result = await repo.updateCategory(categoryId, input);
      } else {
        result = await repo.createCategory(input);
      }

      state = const AsyncData(null);
      // Invalidate để tự động nạp lại danh sách mới
      _ref.invalidate(categoryListProvider);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

