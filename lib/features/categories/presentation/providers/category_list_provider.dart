import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/category.dart';
import '../../domain/models/category_type.dart';
import 'category_providers.dart';

final categoryFilterTypeProvider =
    StateProvider<CategoryType>((ref) => CategoryType.expense);

final categoryListProvider =
    AsyncNotifierProvider.autoDispose<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

class CategoryListNotifier extends AutoDisposeAsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final type = ref.watch(categoryFilterTypeProvider);
    final repo = ref.watch(categoryRepositoryProvider);
    return repo.getCategories(type: type);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> deleteCategory(String id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((c) => c.id != id).toList());
    }
  }
}

